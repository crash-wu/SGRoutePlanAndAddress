#
# Be sure to run `pod lib lint SGRoutePlanAndAddress.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SGRoutePlanAndAddress'
  s.version          = '0.0.2'
  s.summary          = ' 数码地名地址搜索，周边搜索，公交站点搜索，公交路线搜索，公交站点坐标搜索，公交路线坐标搜索，驾车路线搜索'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = ' 数码地名地址搜索，周边搜索，公交站点搜索，公交路线搜索，公交站点坐标搜索，公交路线坐标搜索，驾车路线搜索'


  s.homepage         = 'https://github.com/crash-wu/SGRoutePlanAndAddress'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '吴小星' => 'crash_wu@southgis.com' }
  s.source           = { :git => 'https://github.com/crash-wu/SGRoutePlanAndAddress.git', :tag => s.version.to_s }


  s.ios.deployment_target = '8.0'

  s.source_files = 'SGRoutePlanAndAddress/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SGRoutePlanAndAddress' => ['SGRoutePlanAndAddress/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
    s.dependency 'YYModel'
    s.dependency 'SGSHTTPModule'
    s.dependency 'SVProgressHUD'

    s.xcconfig = {

    "FRAMEWORK_SEARCH_PATHS" => "$(HOME)/Library/SDKs/ArcGIS/iOS" ,
    "OTHER_LDFLAGS"  => '-lObjC -framework ArcGIS -l c++',

    'ENABLE_BITCODE' => 'NO',
    'CLANG_ENABLE_MODULES' => 'YES'

    }


end
