platform :ios, '15.0' # Uncomment this line to define a global platform for your project

use_frameworks! # Comment this line if you're not using Swift and don't want to use dynamic frameworks
inhibit_all_warnings! # Ignore all warnings from all pods

use_frameworks!
def ui_pods
    pod 'SnapKit', '5.0.1'
end

def rx_pods
    pod 'RxSwift', '6.5.0'
    pod 'RxCocoa', '6.5.0'
end

def utility_pods
  pod 'Kingfisher', '7.9.0'
end

target 'AvitoFeed' do
    ui_pods
    rx_pods
    utility_pods
end
