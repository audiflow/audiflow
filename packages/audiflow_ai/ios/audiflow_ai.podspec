# Portions of this code are derived from flutter_local_ai
# (https://github.com/kekko7072/flutter_local_ai)
# Copyright (c) 2025 kekko7072
# Licensed under the MIT License

Pod::Spec.new do |s|
  s.name             = 'audiflow_ai'
  s.version          = '0.0.1'
  s.summary          = 'On-device AI capabilities for Audiflow'
  s.description      = <<-DESC
On-device AI capabilities for Audiflow podcast application using Apple Foundation Models.
                       DESC
  s.homepage         = 'https://github.com/reedom/audiflow'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Audiflow' => 'support@audiflow.app' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '26.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
