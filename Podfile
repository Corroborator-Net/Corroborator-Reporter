# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end

target 'ipfs-cam2' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  #pod 'pop', '~> 1.0'
  #pod 'Textile'
  pod 'Alamofire', '~> 4.8.2'
  pod 'SwiftyJSON', '~> 4.0'
end
