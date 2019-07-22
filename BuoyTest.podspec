Pod::Spec.new do |s|
  s.name     = 'BuoyTest'
  s.version  = '0.0.1'
  s.license  = 'Apache License, Version 2.0'
  s.summary  = 'Floatation is a lightweight dependency injection framework that makes it easy to surface dependencies to consuming code'
  s.homepage = 'https://github.com/dfed/Floatation'
  s.authors  = 'Dan Federman'
  s.source   = { :git => 'https://github.com/dfed/Floatation.git', :tag => s.version }
  s.swift_version = '5.0'
  s.source_files = 'BuoyTest/Sources/**/*.{swift}'

  s.dependency 'Floatation', '~> 0.0.1'

  s.weak_framework = "XCTest"
  s.pod_target_xcconfig = {
    'APPLICATION_EXTENSION_API_ONLY' => 'YES',
    'ENABLE_BITCODE' => 'NO',
    'OTHER_LDFLAGS' => '$(inherited) -weak-lswiftXCTest -Xlinker -no_application_extension',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(PLATFORM_DIR)/Developer/Library/Frameworks"',
  }

  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '2.0'
  s.macos.deployment_target = '10.13'
end
