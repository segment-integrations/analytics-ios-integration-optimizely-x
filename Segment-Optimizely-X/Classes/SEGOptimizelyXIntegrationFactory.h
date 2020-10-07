//
//  SEGOptimizelyXIntegrationFactory.h
//  Pods
//
//  Created by ladan nasserian on 8/17/17.
//
//


#import <Foundation/Foundation.h>
#if defined(__has_include) && __has_include(<Analytics/SEGAnalytics.h>)
#import <Analytics/SEGIntegrationFactory.h>
#else
#import <Segment/SEGIntegrationFactory.h>
#endif
#import <OptimizelySDKiOS/OptimizelySDKiOS.h>


@interface SEGOptimizelyXIntegrationFactory : NSObject <SEGIntegrationFactory>

+ (instancetype)instanceWithOptimizely:(OPTLYManager *)optimizely;

@property OPTLYManager *manager;

@end
