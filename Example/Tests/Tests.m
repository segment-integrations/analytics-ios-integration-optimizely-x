//
//  Segment-Optimizely-XTests.m
//  Segment-Optimizely-XTests
//
//  Created by ladanazita on 08/17/2017.
//  Copyright (c) 2017 Segment.com. All rights reserved.
//

// https://github.com/Specta/Specta

void postNotification()
{
    NSError *error;
    NSDictionary *variationDict = @{ @"id" : @"8729081299",
                                     @"key" : @"variation1" };
    OPTLYVariation *variation = [[OPTLYVariation alloc] initWithDictionary:variationDict error:&error];
    NSDictionary *experimentDict = @{ @"status" : @"Running",
                                      @"key" : @"variation_view",
                                      @"layerId" : @"8743920636",
                                      @"trafficAllocation" : @[ @{@"entityId" : @"8737441336", @"endOfRange" : @5000}, @{@"entityId" : @"8729081299", @"endOfRange" : @10000} ],
                                      @"audienceIds" : @[],
                                      @"variations" : @[ @{@"variables" : @[], @"id" : @"8729081299", @"key" : @"variation1"}, @{@"variables" : @[], @"id" : @"8737441336", @"key" : @"variation2"} ],
                                      @"forcedVariations" : @{},
                                      @"id" : @"8734392016" };

    OPTLYExperiment *experiment = [[OPTLYExperiment alloc] initWithDictionary:experimentDict error:&error];

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
        OptimizelyNotificationsUserDictionaryVariationKey : variation,
        OptimizelyNotificationsUserDictionaryExperimentKey : experiment
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:OptimizelyDidActivateExperimentNotification object:nil userInfo:userInfo];
}


SpecBegin(InitialSpecs);

describe(@"SEGOptimizelyXIntegration", ^{

    __block id mockOptimizelyX;
    __block id mockOptimizelyManager;
    __block SEGAnalytics *mockAnalytics;
    __block SEGOptimizelyXIntegration *integration;

    beforeEach(^{
        mockOptimizelyX = mock([OPTLYClient class]);
        mockOptimizelyManager = mock([OPTLYManager class]);
        mockAnalytics = mock([SEGAnalytics class]);
        [given([mockOptimizelyManager getOptimizely]) willReturn:mockOptimizelyX];
    });


    describe(@"Unknown Users", ^{
        beforeEach(^{
            integration = [[SEGOptimizelyXIntegration alloc] initWithSettings:@{
                @"trackKnownUsers" : @0,
                @"listen" : @1,
                @"nonInteraction" : @1

            } andOptimizelyManager:mockOptimizelyManager withAnalytics:mockAnalytics];
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
            integration = [[SEGOptimizelyXIntegration alloc] initWithSettings:@{
                @"trackKnownUsers" : @1,
                @"listen" : @1,
                @"nonInteraction" : @1
            } andOptimizelyManager:mockOptimizelyManager withAnalytics:mockAnalytics];
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

    describe(@"Experiment Viewed", ^{
        it(@"tracks Experiment Viewed", ^{
            integration = [[SEGOptimizelyXIntegration alloc] initWithSettings:@{
                @"trackKnownUsers" : @1,
                @"listen" : @1,
                @"nonInteraction" : @1
            } andOptimizelyManager:mockOptimizelyManager withAnalytics:mockAnalytics];
            ;
            postNotification();
            [verify(mockAnalytics) track:@"Experiment Viewed" properties:@{ @"experimentId" : @"8734392016",
                                                                            @"experimentName" : @"variation_view",
                                                                            @"nonInteraction" : @1,
                                                                            @"variationId" : @"8729081299",
                                                                            @"variationName" : @"variation1" }
                                 options:@{ @"integrations" : @{@"Optimizely X" : @0} }];
        });

        it(@"tracks Experiment Viewed with noninteraction: false", ^{
            integration = [[SEGOptimizelyXIntegration alloc] initWithSettings:@{
                @"trackKnownUsers" : @1,
                @"listen" : @1,
                @"nonInteraction" : @0
            } andOptimizelyManager:mockOptimizelyManager withAnalytics:mockAnalytics];
            postNotification();
            [verify(mockAnalytics) track:@"Experiment Viewed" properties:@{ @"experimentId" : @"8734392016",
                                                                            @"experimentName" : @"variation_view",
                                                                            @"variationId" : @"8729081299",
                                                                            @"variationName" : @"variation1" }
                                 options:@{ @"integrations" : @{@"Optimizely X" : @0} }];
        });
    });

});

SpecEnd
