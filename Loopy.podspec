Pod::Spec.new do |s|
  s.name         = "Loopy"
  s.version      = "0.1"
  s.summary      = "The next-generation Socialize framework from ShareThis."
  s.description  = "Loopy is ShareThis' successor to the Socialize SDK, allowing iOS applications to interact with the Loopy REST API."
  s.homepage     = "https://github.com/socialize/socialize-networking"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "David Jedeikin" => "djedeikin@sharethis.com" }
  s.platform     = :ios
  s.dependency     'SZNetworking'
  s.source       = { :git => "https://github.com/socialize/loopy-sdk-ios.git", :tag => "0.1" }
  s.source_files = 'Loopy/**/*.{h,m}'
 end
