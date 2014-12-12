source 'https://github.com/socialize/SocializeCocoaPods.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'
inhibit_all_warnings!

xcodeproj 'Loopy'

link_with 'Loopy', 'TestApp'
pod 'AFNetworking', '~> 2.2'

target 'UnitTests' , :exclusive => true do
  link_with ['UnitTests', 'IntegrationTests']
  pod 'Loopy', :path => './Loopy.podspec'
  pod 'GHUnitIOS', :podspec => 'https://raw.githubusercontent.com/socialize/gh-unit/master/GHUnitIOS.podspec'
  pod 'OCMock', :podspec => 'https://raw.githubusercontent.com/socialize/ocmock/master/OCMock.podspec'
end
