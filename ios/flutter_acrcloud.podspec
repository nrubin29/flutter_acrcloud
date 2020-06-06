#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_acrcloud.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_acrcloud'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for the ACRCloud music recognition API'
  s.description      = <<-DESC
A Flutter plugin for the ACRCloud music recognition API
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  s.vendored_libraries = 'Libs/acrcloud/libACRCloud_IOS_SDK.a'
  s.frameworks = 'AudioToolbox', 'AVFoundation', 'Security'
  s.library = 'stdc++'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
