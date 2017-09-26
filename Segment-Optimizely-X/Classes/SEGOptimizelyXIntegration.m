//
//  SEGOptimizelyXIntegration.m
//  Pods
//
//  Created by ladan nasserian on 8/17/17.
//
//

#import "SEGOptimizelyXIntegration.h"
#import <Analytics/SEGIntegration.h>
#import <Analytics/SEGAnalyticsUtils.h>
#import <Analytics/SEGAnalytics.h>


@implementation SEGOptimizelyXIntegration

#pragma mark - Initialization

- (instancetype)initWithSettings:(NSDictionary *)settings andOptimizelyManager:(OPTLYManager *)manager withAnalytics:(SEGAnalytics *)analytics
{
    if (self = [super init]) {
        self.settings = settings;
        self.manager = manager;
        self.analytics = analytics;
    }

    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:OptimizelyDidActivateExperimentNotification
                                                                      object:nil
                                                                       queue:nil
                                                                  usingBlock:^(NSNotification *_Nonnull note) {
                                                                      [self experimentDidGetViewed:note];
                                                                  }];
    return self;
}

- (void)identify:(SEGIdentifyPayload *)payload
{
    if ([self.manager getOptimizely] == nil) {
        [self enqueueAction:payload];
    } else {
        self.client = [self.manager getOptimizely];
        if (payload.userId) {
            self.userId = payload.userId;
        }
    }
}


- (void)track:(SEGTrackPayload *)payload
{
    if ([self.manager getOptimizely] == nil) {
        [self enqueueAction:payload];
    } else {
        self.client = [self.manager getOptimizely];
        // Segment will default sending `track` calls with `anonymousId`s since Optimizely X does not alias known and unknown users
        // https://developers.optimizely.com/x/solutions/sdks/reference/index.html?language=objectivec&platform=mobile#user-ids
        NSString *segmentAnonymousId = [self.analytics getAnonymousId];
        BOOL trackKnownUsers = [[self.settings objectForKey:@"trackKnownUsers"] boolValue];

        if (trackKnownUsers && [self.userId length] == 0) {
            SEGLog(@"Segment will only track users associated with a userId when the trackKnownUsers setting is enabled.");
            return;
        } else if (trackKnownUsers && self.userId) {
            [self.client track:payload.event userId:self.userId attributes:payload.properties];
            SEGLog(@"[optimizely track:@% userId:@% attributes:@%]", payload.event, self.userId, payload.properties);
        } else {
            [self.client track:payload.event userId:segmentAnonymousId attributes:payload.properties];
            SEGLog(@"[optimizely track:@% userId:@% attributes:@%]", payload.event, segmentAnonymousId, payload.properties);
        }
    }
}

- (void)reset
{
    if ([self.manager getOptimizely] == nil) {
        return;
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
        SEGLog(@"[NSNotificationCenter defaultCenter] removeObserver:@%", self.observer);
    }
}


- (void)experimentDidGetViewed:(NSNotification *)notification
{
    OPTLYExperiment *experiment = notification.userInfo[OptimizelyNotificationsUserDictionaryExperimentKey];
    OPTLYVariation *variation = notification.userInfo[OptimizelyNotificationsUserDictionaryVariationKey];
    NSDictionary *properties = @{
        @"experimentId" : [experiment experimentId],
        @"experimentName" : [experiment experimentKey],
        @"variationId" : [variation variationId],
        @"variationName" : [variation variationKey]
    };

    // Trigger event as per our spec https://segment.com/docs/spec/ab-testing/
    [self.analytics track:@"Experiment Viewed" properties:properties];
    SEGLog(@"[[SEGAnalytics sharedAnalytics] track:@'Experiment Viewed' properties:%@", properties);
}

#pragma mark - Queueing

// If Optimizely is not initialized, add events to queue
// Check if Optimizely has been initialized every 30 seconds
// If not initialized, continue adding to a queue
// If initialized, for each item in queue, trigger respective analytics call
// Once queue is empty, release


- (void)enqueueAction:(SEGPayload *)payload
{
    SEGLog(@"%@ Optimizely not initialized. Enqueueing action: %@", self, payload);
    [self queuePayload:[payload copy]];
}

- (void)queuePayload:(NSDictionary *)payload
{
    @try {
        if (self.queue.count > 1000) {
            // Remove the oldest element.
            [self.queue removeObjectAtIndex:0];
        }
        [self.queue addObject:payload];
    }
    @catch (NSException *exception) {
        SEGLog(@"%@ Error writing payload: %@", self, exception);
    }
}

// How to store queue
//- (void)persistQueue
//{
//    [self.storage setArray:[self.queue copy] forKey:@"segment.integration.optimizelyx.queue.plist"];
//}

- (NSMutableArray *)queue
{
    if (!_queue) {
        _queue = [[self.storage arrayForKey:@"SEGOptimizelyQueue"] ?: @[] mutableCopy];
    }

    return _queue;
}

- (void)setupTimer
{
    self.flushTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(isOptimizelyInitialized) userInfo:nil repeats:YES];
}

// Should I be using fact enumeration or enumerateUsingBlock?
- (void)flushQueue:(NSMutableArray *)queue
{
    [queue enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        if (queue == nil) {
            *stop = YES;
        } else if ([obj isKindOfClass:[SEGTrackPayload class]]) {
            [self track:obj];
        } else if ([obj isKindOfClass:[SEGScreenPayload class]]) {
            [self screen:obj];
        } else if ([obj isKindOfClass:[SEGIdentifyPayload class]]) {
            [self identify:obj];
        } else if ([obj isKindOfClass:[SEGGroupPayload class]]) {
            [self group:obj];
        } else {
            SEGLog(@"Fail to assess class. Stopping");
            *stop = YES;
        }
    }];
}

- (BOOL)isOptimizelyInitialized
{
    if ([self.manager getOptimizely] == nil) {
        return @NO;
    } else {
        [self.flushTimer invalidate];
        self.flushTimer = nil;
        [self flushQueue:self.queue];
        return @YES;
    }
}

@end
