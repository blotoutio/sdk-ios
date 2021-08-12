#
#  Be sure to run `pod spec lint Blotout-Analytics.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name             = "Blotout-Analytics"
  s.module_name      = "BlotoutAnalytics"
  s.version          = "0.9.3"
  s.summary          = "Blotout Mobile Analytics SDK"
  s.description      = <<-DESC
                       Blotout’s SDK offers companies all of the analytics and remarketing tools they are accustomed to,
while offering best-in-class privacy preservation for the company’s users. Blotout’s SDK is out of the
box compliant with GDPR, CCPA & COPPA. Blotout’s SDK uses on-device, distributed edge
computing for Analytics, Messaging and Remarketing, all without using User Personal Data, Device
IDs or IP Addresses.
                       DESC

  s.homepage         = "https://github.com/blotoutio/sdk-ios"
  s.license          =  {:file => 'LICENSE'}
  s.author           = { "Blotout" => "developers@blotout.io" }
  s.source           = { :git => "https://github.com/blotoutio/sdk-ios.git", :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.osx.deployment_target = '10.13'

  s.source_files = [
    'BlotoutAnalytics/**/*.{h,m}',
  ]
end
