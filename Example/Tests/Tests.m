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
    __block NSNotificationCenter *mockObserver;

    beforeEach(^{
        mockOptimizelyX = mock([OPTLYClient class]);
        mockAnalytics = mock([SEGAnalytics class]);
        mockObserver = mock([NSNotificationCenter class]);

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

});


SpecEnd
