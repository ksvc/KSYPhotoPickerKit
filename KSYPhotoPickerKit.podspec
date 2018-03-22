#
#  Be sure to run `pod spec lint KSYPhotoPickerKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "KSYPhotoPickerKit"
  s.version      = "1.0.2"
  s.summary      = "金山云iOS 相册选择工具"

  s.license      = {
:type => 'Proprietary',
:text => <<-LICENSE
      Copyright 2018 kingsoft Ltd. All rights reserved.
      LICENSE
  }
  s.homepage     = 'https://github.com/ksvc/KSYPhotoPickerKit'
  s.authors      = { 'ksyun' => 'zengfanping@kingsoft.com' }
  s.summary      = 'KSYPhotoPickerKit 金山云iOS相册选择组件.'
  s.description  = <<-DESC
      * 金山云iOS 相册选择组件开源 免费 方便开发者集成使用
  DESC
  s.platform     = :ios, '8.1'
  s.ios.deployment_target = '8.1'
  s.requires_arc = true
  s.source       = { 
    :git => 'https://github.com/ksvc/KSYPhotoPickerKit.git', 
    :tag => 'v'+s.version.to_s 
  }
  s.resources    = "PhotoPickerKit/*.{png,bundle}"
  s.source_files = "PhotoPickerKit/*.{h,m,xib}"
  s.frameworks   = "Photos"

  s.dependency 'Masonry'
  s.dependency 'YYKit'
  

end
