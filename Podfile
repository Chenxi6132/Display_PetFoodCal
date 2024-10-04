# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'PetFoodCalculator' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PetFoodCalculator
  pod 'XLPagerTabStrip', '~> 9.0'
  pod 'CHTCollectionViewWaterfallLayout/Swift'
  pod 'YPImagePicker'
  pod 'MBProgressHUD', '~> 1.2.0'
  pod 'SKPhotoBrowser'
  pod 'KMPlaceholderTextView', '~> 1.4.0'
  pod 'DateToolsSwift'
  
  pod 'Firebase/AnalyticsWithoutAdIdSupport'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'GoogleSignInSwiftSupport'
  pod 'FirebaseStorage'
  
  pod 'PopupDialog', '~> 1.1'
  pod 'FaveButton'
  pod 'ImageSlideshow', '~> 1.9.0'
  pod 'Kingfisher', '~> 6.0'
  pod "ImageSlideshow/Kingfisher"
  
  pod 'GrowingTextView', '0.7.2'
  pod 'SegementSlide', '3.0.1'
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
      
      # Additional logic specifically for 'BoringSSL-GRPC'
      if target.name == 'BoringSSL-GRPC'
        target.source_build_phase.files.each do |file|
          if file.settings && file.settings['COMPILER_FLAGS']
            flags = file.settings['COMPILER_FLAGS'].split
            flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
            file.settings['COMPILER_FLAGS'] = flags.join(' ')
          end
        end
      end
    end
  end
  
  
end
      
