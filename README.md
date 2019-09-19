# Segment-Optimizely-X

[![CircleCI](https://circleci.com/gh/segment-integrations/analytics-ios-integration-optimizely-x.svg?style=svg)](https://circleci.com/gh/segment-integrations/analytics-ios-integration-optimizely-x)
[![Version](https://img.shields.io/cocoapods/v/Segment-Optimizely-X.svg?style=flat)](http://cocoapods.org/pods/Segment-Optimizely-X)
[![License](https://img.shields.io/cocoapods/l/Segment-Optimizely-X.svg?style=flat)](http://cocoapods.org/pods/Segment-Optimizely-X)
[![Platform](https://img.shields.io/cocoapods/p/Segment-Optimizely-X.svg?style=flat)](http://cocoapods.org/pods/Segment-Optimizely-X)

**This SDK supports Optimizely iOS v1.1.9. Segment supports newer versions of Optimizely via Segment cloud mode. Read more about integrating with Optimizely via Segment cloud mode in [our documentation here](https://segment.com/docs/destinations/optimizely-full-stack/#ios-cloud-mode-implementation).**

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Segment-Optimizely-X is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Segment-Optimizely-X"
```

## Usage

```obj-c
    SEGAnalyticsConfiguration *configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:@"<YOUR_WRITE_KEY>"];
    configuration.trackApplicationLifecycleEvents = YES;
    configuration.recordScreenViews = YES;

    // Setup optimizely logger.
    OPTLYLoggerDefault *optlyLogger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelError];
    // Create an Optimizely manager.
    self.optlyManager = [OPTLYManager init:^(OPTLYManagerBuilder *_Nullable builder) {
        builder.projectId = @"<YOUR_PROJECT_ID>";
        builder.logger = optlyLogger;
    }];
    
    // Initialize an Optimizely client by asynchronously downloading the datafile.
    [self.optlyManager initializeWithCallback:^(NSError *_Nullable error, OPTLYClient *_Nullable client) {
       // Optimizely is now up and running.  You can now configure any experiments, etc.
    }];

    [configuration use:[SEGOptimizelyXIntegrationFactory instanceWithOptimizely:self.optlyManager]];
    [SEGAnalytics setupWithConfiguration:configuration];
```

```swift
    let configuration = SEGAnalyticsConfiguration(writeKey: "<YOUR_WRITE_KEY>")
    configuration.trackApplicationLifecycleEvents = true
    configuration.recordScreenViews = true
    configuration.flushAt = 1
    configuration.middlewares = [ConsentMiddleware()]

    let optlyLogger = OPTLYLoggerDefault(logLevel: .error)
    optlyManager = OPTLYManager.instance(builderBlock: { (builder) in
        builder?.projectId = "<YOUR_PROJECT_ID>"
        builder?.logger = optlyLogger
    })

    optlyManager?.initialize(callback: { (error, optlyClient) in
        // Optimizely is now up and running.  You can now configure any experiments, etc.
    })

    configuration.use(SEGOptimizelyXIntegrationFactory.instance(withOptimizely: optlyManager))

    SEGAnalytics.setup(with: configuration)
```

## License

Segment-Optimizely-X is available under the MIT license. See the LICENSE file for more info.
