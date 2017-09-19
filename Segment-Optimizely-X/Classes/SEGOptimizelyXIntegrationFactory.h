//
//  SEGOptimizelyXIntegrationFactory.h
//  Pods
//
//  Created by ladan nasserian on 8/17/17.
//
//


#import <Foundation/Foundation.h>
#import <Analytics/SEGIntegrationFactory.h>
#import <OptimizelySDKiOS/OptimizelySDKiOS.h>


@interface SEGOptimizelyXIntegrationFactory : NSObject <SEGIntegrationFactory>

+ (instancetype)instance;
+ (instancetype)createWithOptimizelyClient:(NSString *)token optimizelyClient:(OPTLYClient *)client;

@property OPTLYClient *client;

@end
