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


@interface SEGOptimizelyXIntegration : NSObject <SEGIntegration>

@property (nonatomic, strong) NSDictionary *settings;
@property (nonatomic, strong) OPTLYClient *client;
@property (nonatomic) id observer;


- (id)initWithSettings:(NSDictionary *)settings andOptimizelyClient:(OPTLYClient *)client;

@end
