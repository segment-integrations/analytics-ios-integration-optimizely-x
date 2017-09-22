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
    __block SEGAnalytics *mockAnalytics;
    __block SEGOptimizelyXIntegration *integration;

    beforeEach(^{
        mockOptimizelyX = mock([OPTLYClient class]);
        mockAnalytics = mock([SEGAnalytics class]);

        integration = [[SEGOptimizelyXIntegration alloc] initWithSettings:@{
            @"trackKnownUsers" : @0
        } andOptimizelyClient:mockOptimizelyX withAnalytics:mockAnalytics];
    });

    it(@"tracks unknown user", ^{
        [given([mockAnalytics getAnonymousId]) willReturn:@"1234"];
        SEGTrackPayload *payload = [[SEGTrackPayload alloc] initWithEvent:@"Event" properties:@{
            @"name" : @"Bob",
            @"gender" : @"male"
        } context:@{
        } integrations:@{}];
        [integration track:payload];
        [verify(mockOptimizelyX) track:@"Event" userId:@"1234" attributes:@{ @"name" : @"Bob",
                                                                             @"gender" : @"male"
        }];
    });

    it(@"tracks known user", ^{
        integration = [[SEGOptimizelyXIntegration alloc] initWithSettings:@{
            @"trackKnownUsers" : @1
        } andOptimizelyClient:mockOptimizelyX withAnalytics:mockAnalytics];
        SEGIdentifyPayload *identifyPayload = [[SEGIdentifyPayload alloc] initWithUserId:@"1234" anonymousId:nil traits:@{} context:@{} integrations:@{}];
        SEGTrackPayload *payload = [[SEGTrackPayload alloc] initWithEvent:@"Event" properties:@{
            @"name" : @"Bob",
            @"gender" : @"male"
        } context:@{
        } integrations:@{}];
        [integration identify:identifyPayload];
        [integration track:payload];
        [verify(mockOptimizelyX) track:@"Event" userId:@"1234" attributes:@{ @"name" : @"Bob",
                                                                             @"gender" : @"male"
        }];
    });

    it(@"does not track if settings.trackKnownUser enabled without userId", ^{
        integration = [[SEGOptimizelyXIntegration alloc] initWithSettings:@{
            @"trackKnownUsers" : @1
        } andOptimizelyClient:mockOptimizelyX withAnalytics:mockAnalytics];
        SEGTrackPayload *payload = [[SEGTrackPayload alloc] initWithEvent:@"Event" properties:@{
            @"name" : @"Bob",
            @"gender" : @"male"
        } context:@{
        } integrations:@{}];
        [integration track:payload];
        [verifyCount(mockOptimizelyX, never()) track:@"Event" userId:@"" attributes:@{
            @"name" : @"Bob",
            @"gender" : @"male"
        }];
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
