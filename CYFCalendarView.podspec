#
# Be sure to run `pod lib lint CYFCalendarView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CYFCalendarView"
  s.version          = "0.1.0"
  s.summary          = "CYFCalendarView displays events of a day like the iOS calendar app."
  s.description      = <<-DESC
                       CYFCalendarView displays events of a day like the iOS calendar app. You can drag and drop an event to change it's' start and end time.
                       DESC
  s.homepage         = "https://github.com/<GITHUB_USERNAME>/CYFCalendarView"
  s.license          = 'MIT'
  s.author           = { "yifeic" => "yifei.chen@outlook.com" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/CYFCalendarView.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/victoryifei'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'CYFCalendarView' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'libextobjc/EXTScope'
end
