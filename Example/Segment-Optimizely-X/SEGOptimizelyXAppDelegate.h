//
//  SEGOptimizelyXAppDelegate.h
//  Segment-Optimizely-X
//
//  Created by ladanazita on 08/17/2017.
//  Copyright (c) 2017 Segment.com. All rights reserved.
//

#import <OptimizelySDKiOS/OptimizelySDKiOS.h>
#import <OptimizelySDKiOS/OPTLYManager.h>

@import UIKit;


@interface SEGOptimizelyXAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property OPTLYManager *optlyManager;


@end
