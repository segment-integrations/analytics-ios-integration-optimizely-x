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

- (instancetype)initWithSettings:(NSDictionary *)settings andOptimizelyClient:(OPTLYClient *)client withAnalytics:(SEGAnalytics *)analytics
{
    if (self = [super init]) {
        self.settings = settings;
        self.client = client;
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
    if (payload.userId) {
        self.userId = payload.userId;
    }
}


- (void)track:(SEGTrackPayload *)payload
{
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

- (void)reset
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
    SEGLog(@"[NSNotificationCenter defaultCenter] removeObserver:@%", self.observer);
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
@end
