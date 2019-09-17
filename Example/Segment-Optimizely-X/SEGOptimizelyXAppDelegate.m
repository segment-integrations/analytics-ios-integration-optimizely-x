//
//  SEGOptimizelyXAppDelegate.m
//  Segment-Optimizely-X
//
//  Created by ladanazita on 08/17/2017.
//  Copyright (c) 2017 Segment.com. All rights reserved.
//

#import "SEGOptimizelyXAppDelegate.h"
#import <Analytics/SEGAnalytics.h>
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
    OPTLYManagerBuilder *builder = [OPTLYManagerBuilder builderWithBlock:^(OPTLYManagerBuilder *builder) {
        builder.projectId = @"8724802167";
        builder.logger = optlyLogger;

    }];
    self.optlyManager = [[OPTLYManager alloc] initWithBuilder:builder];

    // https://docs.developers.optimizely.com/full-stack/docs/use-synchronous-or-asynchronous-initialization
    //Optimizely must be initialized synchronously so that the client is available when the SEGOptimizelyXIntegration is created.
    //In a real app, you might bundle the Optimizely data file to load it from disk and then update as needed from a server.
    //In this example, the file is fetched on launch and cached for later use.
    //On first launch, the file is not yet available when the SEGOptimizelyXIntegration is created.
    //On second launch, the cached data file is available when SEGOptimizelyXIntegration gets created.
    OPTLYClient *optimizely = [self.optlyManager initialize];
    
    [configuration use:[SEGOptimizelyXIntegrationFactory instanceWithOptimizely:self.optlyManager]];
    [SEGAnalytics setupWithConfiguration:configuration];
    [[SEGAnalytics sharedAnalytics] track:@"Testing if malformed"];
    [[SEGAnalytics sharedAnalytics] identify:@"3942084234230" traits:@{
        @"gender" : @"female",
        @"company" : @"segment",
        @"name" : @"ladan"
    }];
    
    // Activate user in an experiment, delayed until Segment has been initialized
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [optimizely activate:@"variation_view" userId:@"1234"];
    });


    return YES;
}

@end
