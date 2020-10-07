//
//  SEGOptimizelyXAppDelegate.m
//  Segment-Optimizely-X
//
//  Created by ladanazita on 08/17/2017.
//  Copyright (c) 2017 Segment.com. All rights reserved.
//

#import "SEGOptimizelyXAppDelegate.h"
#if defined(__has_include) && __has_include(<Analytics/SEGAnalytics.h>)
#import <Analytics/SEGAnalytics.h>
#else
#import <Segment/SEGAnalytics.h>
#endif
#import "SEGOptimizelyXIntegrationFactory.h"


@implementation SEGOptimizelyXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // https://segment.com/ladanazita/sources/ios_test/overview
    SEGAnalyticsConfiguration *configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:@"ACIG3kwqCUsWZBfYxZDu0anuGwP3XtWW"];
    configuration.trackApplicationLifecycleEvents = YES;
    configuration.recordScreenViews = YES;
    [SEGAnalytics debug:YES];

    OPTLYLoggerDefault *optlyLogger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelError];
    // Initialize an Optimizely manager
    self.optlyManager = [OPTLYManager init:^(OPTLYManagerBuilder *_Nullable builder) {
        builder.projectId = @"8724802167";
        builder.logger = optlyLogger;

    }];

    [configuration use:[SEGOptimizelyXIntegrationFactory instanceWithOptimizely:self.optlyManager]];
    [SEGAnalytics setupWithConfiguration:configuration];
    [[SEGAnalytics sharedAnalytics] track:@"Testing if malformed"];
    [[SEGAnalytics sharedAnalytics] identify:@"3942084234230" traits:@{
        @"gender" : @"female",
        @"company" : @"segment",
        @"name" : @"ladan"
    }];

    // Test delayed initialization
    double delayInSeconds = 10.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

        // Initialize an Optimizely client by asynchronously downloading the datafile
        [self.optlyManager initializeWithCallback:^(NSError *_Nullable error, OPTLYClient *_Nullable client) {
            // Activate user in an experiment
            OPTLYVariation *variation = [client activate:@"variation_view" userId:@"1234"];

            if ([variation.variationKey isEqualToString:@"variation1"]) {
                [[SEGAnalytics sharedAnalytics] track:@"Test variation 1"];
            } else if ([variation.variationKey isEqualToString:@"variation 2"]) {
                [[SEGAnalytics sharedAnalytics] track:@"Test variation2"];
            } else {
                [[SEGAnalytics sharedAnalytics] track:@"No variation triggered"];
            }
        }];
    });


    return YES;
}

@end
