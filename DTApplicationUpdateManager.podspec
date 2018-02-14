#
# Be sure to run `pod lib lint DTApplicationUpdateManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DTApplicationUpdateManager'
  s.version          = '0.1.0'
  s.summary          = 'A simple manager which checks if there is any newer app\'s version available in the AppStore.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Whenever you roll out a new version to the AppStore, you might want the user to update to that newly released version. DTApplicationUpdateManager helps to let the app notified about the new version. If the uesr ignored that version, DTApplicationUpdateManager is still able to remind in the next time in a flexible way.
                       DESC

  s.homepage         = 'https://github.com/ducthinh2410/DTApplicationUpdateManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'thinhv@metropolia.fi' => 'ducthinh2410@gmail.com' }
  s.source           = { :git => 'https://github.com/ducthinh2410/DTApplicationUpdateManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'DTApplicationUpdateManager/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DTApplicationUpdateManager' => ['DTApplicationUpdateManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
