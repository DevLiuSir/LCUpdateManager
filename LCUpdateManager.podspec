#
#  Be sure to run `pod spec lint LCUpdateManager.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name           = "LCUpdateManager"
  
  spec.version        = "1.0.0"
  
  spec.summary        = "LCUpdateManager is a Cocoa framework used to detect AppStore application updates"
  
  spec.description    = <<-DESC
                LCUpdateManager is a Cocoa framework used to detect AppStore application updates！
                   DESC

  spec.homepage       = "https://github.com/DevLiuSir/LCUpdateManager"
  
  spec.license        = { :type => "MIT", :file => "LICENSE" }
  
  spec.author         = { "Marvin" => "93428739@qq.com" }
  
  spec.swift_versions = ['5.0']
  
  spec.platform       = :osx

  spec.osx.deployment_target = "10.15"
  
  spec.source         = { :git => "https://github.com/DevLiuSir/LCUpdateManager.git", :tag => "#{spec.version}" }

  spec.source_files   = "Sources/LCUpdateManager/**/*.{h,m,swift}"
  
  #spec.resource       = 'Sources/LCUpdateManager/Resources/**/*.strings'
  sec.resource_bundles = {
    'LCUpdateManager' => ['Sources/LCUpdateManager/Resources/**/*']
  }

end
