Pod::Spec.new do |s|
  s.name             = 'Segment-Optimizely-X'
  s.version          = '1.0.4'
  s.summary          = "Optimizely X Integration for Segment's analytics-ios library."

  s.description      = <<-DESC
Analytics for iOS provides a single API that lets you
integrate with over 100s of tools.
This is the Optimizely X integration for the iOS library.
                       DESC

  s.homepage         = 'http://segment.com/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Segment' => 'friends@segment.com' }
  s.source           = { :git => 'https://github.com/segment-integrations/analytics-ios-integration-optimizely-x.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/segment'

  s.ios.deployment_target = '8.0'

    s.source_files = 'Segment-Optimizely-X/Classes/**/*'
    s.dependency 'Analytics', '~> 3.0'
    s.dependency 'OptimizelySDKiOS', '~> 1.1.9'

end
