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

@property (nonatomic, strong) NSDictionary *settings;
@property (nonatomic, strong) OPTLYClient *client;
@property (nonatomic) id observer;
@property (nonatomic) NSString *userId;
@property (nonatomic, strong) SEGAnalytics *analytics;


- (id)initWithSettings:(NSDictionary *)settings andOptimizelyClient:(OPTLYClient *)client withAnalytics:(SEGAnalytics *)analytics;

@end
