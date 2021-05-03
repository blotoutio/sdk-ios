#
#  Be sure to run `pod spec lint Blotout-Analytics.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "Blotout-Analytics"
  spec.version      = "0.7.1"
  spec.summary      = "Blotout Mobile Analytics SDK"
  spec.source           = { :git => 'https://github.com/blotoutio/sdk-ios.git', :tag => '0.7.1' }
  spec.source_files   = 'dist/sdk/**/*'
  spec.public_header_files = 'dist/sdk/**/*.h'
  spec.vendored_libraries = 'dist/sdk/libBlotoutAnalytics.a'
  spec.platform = :ios, '12.0'
  spec.static_framework = true

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
                       Blotout’s SDK offers companies all of the analytics and remarketing tools they are accustomed to,
while offering best-in-class privacy preservation for the company’s users. Blotout’s SDK is out of the
box compliant with GDPR, CCPA & COPPA. Blotout’s SDK uses on-device, distributed edge
computing for Analytics, Messaging and Remarketing, all without using User Personal Data, Device
IDs or IP Addresses.
                       DESC

  spec.homepage     = "https://github.com/blotoutio/sdk-ios"
  spec.license      = {:file => 'LICENSE'}
  spec.author             = { "Blotout" => "developers@blotout.io" }
  #spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  
  
end
