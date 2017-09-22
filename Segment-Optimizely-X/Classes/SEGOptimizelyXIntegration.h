//
//  SEGOptimizelyXIntegration.h
//  Pods
//
//  Created by ladan nasserian on 8/17/17.
//
//

#import <Foundation/Foundation.h>
#import <Analytics/SEGIntegration.h>
#import <OptimizelySDKiOS/OptimizelySDKiOS.h>
#import "SEGAnalytics.h"


@interface SEGOptimizelyXIntegration : NSObject <SEGIntegration>

@property (nonatomic, strong, nonnull) NSDictionary *settings;
@property (nonatomic, strong, nonnull) OPTLYClient *client;
@property (nonatomic, nullable) id observer;
@property (nonatomic, nullable) NSString *userId;
@property (nonatomic, strong, nonnull) SEGAnalytics *analytics;


- (id _Nonnull)initWithSettings:(NSDictionary *_Nonnull)settings andOptimizelyClient:(OPTLYClient *_Nonnull)client withAnalytics:(SEGAnalytics *_Nonnull)analytics;

@end
