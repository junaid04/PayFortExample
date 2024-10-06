# Uncomment the next line to define a global platform for your project
 platform :ios, '15.6'

target 'FortPaymentExample' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    
    # Pods for FortPaymentExample
    pod 'Alamofire', '4.9.1'
    
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.6'
        end
    end
end
