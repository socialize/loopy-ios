Pod::Spec.new do |s|
  s.name         = "Loopy"
  s.version      = "1.0.0-RC2"
  s.summary      = "iOS SDK for the Loopy Social Analytics Platform."
  s.description  = "Allows iOS applications to interact with the Loopy API to provide rich sharing analytics."
  s.homepage     = "https://github.com/socialize/socialize-networking"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "David Jedeikin" => "djedeikin@sharethis.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/socialize/loopy-sdk-ios.git", :tag => "1.0.0-RC2" }
  s.source_files = 'Loopy/**/*.{h,m}'
  s.resources    = 'Loopy/Resources/*.png'
 end
