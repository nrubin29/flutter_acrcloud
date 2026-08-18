#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_acrcloud.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_acrcloud'
  s.version          = '2.0.0'
  s.summary          = 'A Flutter plugin for the ACRCloud music recognition API.'
  s.description      = <<-DESC
A Flutter plugin for the ACRCloud music recognition API. Provides a simple
interface for recognizing music from the device's microphone.
                       DESC
  s.homepage         = 'https://github.com/nrubin29/flutter_acrcloud'
  s.license          = { :type => 'BSD-3-Clause', :file => '../LICENSE' }
  s.author           = { 'Noah Rubin' => 'nrubin29@gmail.com' }
  s.source           = { :path => '.' }

  s.source_files        = 'flutter_acrcloud/Sources/flutter_acrcloud/**/*.swift'
  s.vendored_frameworks = 'flutter_acrcloud/Frameworks/ACRCloudiOSSDK.xcframework'
  s.resource_bundles    = {
    'flutter_acrcloud_privacy' => ['flutter_acrcloud/Sources/flutter_acrcloud/PrivacyInfo.xcprivacy']
  }

  s.frameworks = 'AVFoundation', 'AudioToolbox', 'Security'
  s.libraries  = 'c++'

  s.dependency 'Flutter'
  s.platform = :ios, '15.0'
  s.swift_version = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
