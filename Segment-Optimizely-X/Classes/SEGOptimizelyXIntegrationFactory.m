//
//  SEGOptimizelyXIntegrationFactory.m
//  Pods
//
//  Created by ladan nasserian on 8/17/17.
//
//

#import "SEGOptimizelyXIntegrationFactory.h"
#import "SEGOptimizelyXIntegration.h"
#import <OptimizelySDKiOS/OptimizelySDKiOS.h>


@implementation SEGOptimizelyXIntegrationFactory

+ (instancetype)instanceWithOptimizely:(OPTLYManager *)optimizely
{
    static dispatch_once_t once;
    static SEGOptimizelyXIntegrationFactory *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithOptimizely:nil];
    });
    return sharedInstance;
}

- (id)initWithOptimizely:(OPTLYClient *)client
{
    if (self = [super init]) {
        self.client = client;
    }

    return self;
}

+ (instancetype)createWithOptimizelyClient:(NSString *)token optimizelyClient:(OPTLYClient *)client
{
    return [[self alloc] initWithOptimizely:client];
}

- (id<SEGIntegration>)createWithSettings:(NSDictionary *)settings forAnalytics:(SEGAnalytics *)analytics
{
    return [[SEGOptimizelyXIntegration alloc] initWithSettings:settings andOptimizelyClient:self.client withAnalytics:analytics];
}

- (NSString *)key
{
    return @"Optimizely X";
}


@end
