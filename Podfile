=begin
    You can add comments in a Podfile by using the Ruby comment syntax.
=end
inhibit_all_warnings!

source 'https://github.com/CocoaPods/Specs'

# So that third party libraries written in Objective-C will be connected as frameworks rather than static libraries.
# http://iosdevbits.blogspot.com.by/2014/12/finally-cocoapods-with-swift.html
use_frameworks!

platform :ios, '12.0'

target "Networking" do

pod 'Alamofire', '~> 5.0.0-rc.2'
pod 'ReachabilitySwift', '~> 5.0.0-beta1'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if ['Alamofire', 'Gloss', 'Alamofire-Gloss'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end
end

