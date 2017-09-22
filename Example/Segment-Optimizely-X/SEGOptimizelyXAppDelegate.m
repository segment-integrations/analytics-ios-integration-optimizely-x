//
//  SEGOptimizelyXAppDelegate.m
//  Segment-Optimizely-X
//
//  Created by ladanazita on 08/17/2017.
//  Copyright (c) 2017 Segment.com. All rights reserved.
//

#import "SEGOptimizelyXAppDelegate.h"
#import <Analytics/SEGAnalytics.h>
#import <OptimizelySDKiOS/OptimizelySDKiOS.h>
#import "SEGOptimizelyXIntegrationFactory.h"


@implementation SEGOptimizelyXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // https://segment.com/ladanazita/sources/ios_test/overview
    SEGAnalyticsConfiguration *configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:@"ACIG3kwqCUsWZBfYxZDu0anuGwP3XtWW"];
    configuration.trackApplicationLifecycleEvents = YES;
    configuration.recordScreenViews = YES;
    [SEGAnalytics debug:YES];

    // Initialize an Optimizely manager
    OPTLYManager *optlyManager = [OPTLYManager init:^(OPTLYManagerBuilder *_Nullable builder) {
        builder.projectId = @"8724802167";
    }];


    // Provide instance to Segment-Optimizely-X Integration
    [configuration use:[SEGOptimizelyXIntegrationFactory instanceWithOptimizely:optlyManager]];
    [SEGAnalytics setupWithConfiguration:configuration];

    // Initialize an Optimizely client by asynchronously downloading the datafile
    [optlyManager initializeWithCallback:^(NSError *_Nullable error, OPTLYClient *_Nullable client) {
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

    return YES;
}

@end
