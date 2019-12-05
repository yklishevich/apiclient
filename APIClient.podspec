Pod::Spec.new do |s|
  s.name            = "APIClient"
  s.version         = "1.0.8"
  s.summary         = "Networking client over Alamofire allowing to get typed responses."
  s.description     = <<-DESC
					 Allows to make requests to json web services and receive response directly in typed object
					 conforming native Apple's Decodable protocol
                    DESC

  s.homepage        = "https://github.com/yklishevich/apiclient"
  s.license         = { :type => "MIT", :file => "LICENSE.txt" }
  s.author             = { "Yauheni Klishevich" => "eklishevich@gmail.com" }
  s.platform        = :ios, "11.0"
  s.swift_version   = '5.0'
  s.source          = { :git => "https://github.com/yklishevich/apiclient.git", :tag => "1.0.7" }
  s.source_files    = "APIClient/Source/**/*.swift"
  s.exclude_files   = "Classes/Exclude"
  s.framework       = "Foundation"
  s.requires_arc    = true
  
  s.dependency 'Alamofire', '~> 5.0.0-rc.3'
  s.dependency 'ReachabilitySwift', '~> 5.0.0'

end
