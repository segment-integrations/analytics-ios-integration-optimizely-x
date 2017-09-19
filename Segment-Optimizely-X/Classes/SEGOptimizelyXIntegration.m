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

- (instancetype)initWithSettings:(NSDictionary *)settings andOptimizelyClient:(OPTLYClient *)client
{
    if (self = [super init]) {
        self.client = client;
    }

    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:OptimizelyDidActivateExperimentNotification
                                                                      object:nil
                                                                       queue:nil
                                                                  usingBlock:^(NSNotification *_Nonnull note) {
                                                                      [self experimentDidGetViewed:note];
                                                                  }];
    return self;
}


- (void)track:(SEGTrackPayload *)payload
{
    // Segment will not send in `track` calls with `anonymousId`s since Optimizely X does not alias known and unknown users
    // https://developers.optimizely.com/x/solutions/sdks/reference/index.html?language=objectivec&platform=mobile#user-ids

    if (payload.properties[@"user_id"]) {
        [self.client track:payload.event userId:payload.properties[@"user_id"] attributes:payload.properties];
        SEGLog(@"[optimizely track:@% userId:@% attributes:@%]", payload.event, payload.properties[@"user_id"], payload.properties);
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
    [[SEGAnalytics sharedAnalytics] track:@"Experiment Viewed" properties:properties];
    SEGLog(@"[[SEGAnalytics sharedAnalytics] track:@'Experiment Viewed' properties:%@", properties);
}
@end
