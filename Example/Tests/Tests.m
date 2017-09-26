//
//  Segment-Optimizely-XTests.m
//  Segment-Optimizely-XTests
//
//  Created by ladanazita on 08/17/2017.
//  Copyright (c) 2017 Segment.com. All rights reserved.
//

// https://github.com/Specta/Specta

SpecBegin(InitialSpecs);

describe(@"SEGOptimizelyXIntegration", ^{

    __block id mockOptimizelyX;
    __block id mockOptimizelyManager;
    __block SEGAnalytics *mockAnalytics;
    __block SEGOptimizelyXIntegration *integration;

    describe(@"Unknown Users", ^{
        beforeEach(^{
            mockOptimizelyX = mock([OPTLYClient class]);
            mockOptimizelyManager = mock([OPTLYManager class]);
            mockAnalytics = mock([SEGAnalytics class]);

            integration = [[SEGOptimizelyXIntegration alloc] initWithSettings:@{
                @"trackKnownUsers" : @0
            } andOptimizelyManager:mockOptimizelyManager withAnalytics:mockAnalytics];
            [given([mockOptimizelyManager getOptimizely]) willReturn:mockOptimizelyX];

        });

        it(@"tracks unknown user without attributes", ^{
            [given([mockAnalytics getAnonymousId]) willReturn:@"1234"];
            SEGTrackPayload *payload = [[SEGTrackPayload alloc] initWithEvent:@"Event" properties:@{
                @"name" : @"Bob",
                @"gender" : @"male"
            } context:@{
            } integrations:@{}];
            [integration track:payload];
            [verify(mockOptimizelyX) track:@"Event" userId:@"1234" eventTags:@{ @"name" : @"Bob",
                                                                                @"gender" : @"male"
            }];
        });

        it(@"tracks unknown user with attributes", ^{
            [given([mockAnalytics getAnonymousId]) willReturn:@"1234"];
            SEGIdentifyPayload *identifyPayload = [[SEGIdentifyPayload alloc] initWithUserId:nil anonymousId:nil traits:@{
                @"gender" : @"female",
                @"company" : @"segment",
                @"name" : @"ladan"
            } context:@{}
                integrations:@{}];
            SEGTrackPayload *payload = [[SEGTrackPayload alloc] initWithEvent:@"Event" properties:@{
                @"plan" : @"Pro Annual",
                @"accountType" : @"Facebook"
            } context:@{
            } integrations:@{}];
            [integration identify:identifyPayload];
            [integration track:payload];
            [verify(mockOptimizelyX) track:@"Event" userId:@"1234" attributes:@{
                @"gender" : @"female",
                @"company" : @"segment",
                @"name" : @"ladan"
            } eventTags:@{
                @"plan" : @"Pro Annual",
                @"accountType" : @"Facebook"
            }];
        });

    });

    describe(@"Known Users", ^{
        beforeEach(^{
            mockOptimizelyX = mock([OPTLYClient class]);
            mockOptimizelyManager = mock([OPTLYManager class]);
            mockAnalytics = mock([SEGAnalytics class]);

            integration = [[SEGOptimizelyXIntegration alloc] initWithSettings:@{
                @"trackKnownUsers" : @1
            } andOptimizelyManager:mockOptimizelyManager withAnalytics:mockAnalytics];

            [given([mockOptimizelyManager getOptimizely]) willReturn:mockOptimizelyX];

        });

        it(@"does not track if settings.trackKnownUser enabled without userId", ^{
            SEGTrackPayload *payload = [[SEGTrackPayload alloc] initWithEvent:@"Event" properties:@{
                @"plan" : @"Pro Annual",
                @"accountType" : @"Facebook"
            } context:@{
            } integrations:@{}];
            [integration track:payload];
            [verifyCount(mockOptimizelyX, never()) track:@"Event" userId:@"" attributes:@{} eventTags:@{
                @"plan" : @"Pro Annual",
                @"accountType" : @"Facebook"
            }];
        });

        it(@"tracks known user with attributes", ^{
            SEGIdentifyPayload *identifyPayload = [[SEGIdentifyPayload alloc] initWithUserId:@"3942084234230" anonymousId:nil traits:@{
                @"gender" : @"female",
                @"company" : @"segment",
                @"name" : @"ladan"
            } context:@{}
                integrations:@{}];
            SEGTrackPayload *payload = [[SEGTrackPayload alloc] initWithEvent:@"Event" properties:@{
                @"plan" : @"Pro Annual",
                @"accountType" : @"Facebook"
            } context:@{
            } integrations:@{}];
            [integration identify:identifyPayload];
            [integration track:payload];
            [verify(mockOptimizelyX) track:@"Event" userId:@"3942084234230" attributes:@{
                @"gender" : @"female",
                @"company" : @"segment",
                @"name" : @"ladan"
            } eventTags:@{ @"plan" : @"Pro Annual",
                           @"accountType" : @"Facebook"
            }];
        });

        it(@"tracks known user without attributes", ^{
            SEGIdentifyPayload *identifyPayload = [[SEGIdentifyPayload alloc] initWithUserId:@"1234" anonymousId:nil traits:@{} context:@{} integrations:@{}];
            SEGTrackPayload *payload = [[SEGTrackPayload alloc] initWithEvent:@"Event" properties:@{
                @"plan" : @"Pro Annual",
                @"accountType" : @"Facebook"
            } context:@{
            } integrations:@{}];
            [integration identify:identifyPayload];
            [integration track:payload];
            [verify(mockOptimizelyX) track:@"Event" userId:@"1234" eventTags:@{ @"plan" : @"Pro Annual",
                                                                                @"accountType" : @"Facebook"
            }];
        });


    });

    // TODO: revist
    //    it(@"tracks Experiment Viewed", ^{
    //        NSError *error;
    //
    //        NSDictionary *variationDict = @{
    //                                        @"variationId":@"4501",
    //                                        @"variationKey":@"Variation 1"
    //                                        };
    //        OPTLYVariation* variation = [[OPTLYVariation alloc]initWithDictionary:variationDict error:&error];
    //
    //        NSDictionary *experimentDict =  @{
    //                                          @"experimentId":@"e72",
    //                                          @"experimentKey":@"Experiment 1",
    //                                          @"status":@"test status",
    //                                          @"trafficAllocations":@"test traffic",
    //                                          @"forcedVariations":@"example",
    //                                          @"layerId":@"1234",
    //                                          @"variations": @"variations",
    //                                          @"audienceIds":@"audience id"};
    //        OPTLYExperiment* experiment = [[OPTLYExperiment alloc] initWithDictionary:experimentDict error:&error];
    //
    //
    //        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
    //                                                                                        OptimizelyNotificationsUserDictionaryVariationKey: variation ?: @"",
    //                                                                                        OptimizelyNotificationsUserDictionaryExperimentKey:experiment ?: @""
    //                                                                                        }];
    //
    //        [[NSNotificationCenter defaultCenter] postNotificationName:OptimizelyDidActivateExperimentNotification object:self userInfo:userInfo];
    //
    //        [verify(mockAnalytics) track:@"Experiment Viewed" properties:@{ @"experimentId" : @"e72",
    //                                                                        @"experimentName" : @"Experiment 1",
    //                                                                        @"variationId":@"4501",
    //                                                                        @"variationName":@"Variation 1"
    //                                                                      }];
    //    });
});


SpecEnd
