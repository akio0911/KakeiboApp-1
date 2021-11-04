# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'KakeiboApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for KakeiboApp
pod 'SwiftLint'
pod 'RxSwift'
pod 'RxCocoa'
pod 'Firebase/Firestore'
pod 'FirebaseFirestoreSwift'
pod 'Firebase/Auth'
pod 'Firebase/Crashlytics'
pod 'Firebase/Analytics'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
