Pod::Spec.new do |s|
  s.name             = 'MMLanScan'
  s.version          = '3.0.0'
  s.summary          = 'MMLanScan is an open source project for iOS that helps you scan your network and shows the available devices.'
  
  s.description  = <<-DESC
  MMLanScan is an open source project for iOS that helps you scan your network and shows the available devices and their MAC Address, hostname and Brand name. For those updating from 2.1.2 please note that "Device" class has been renamed to "MMDevice". 
  For those updating from 2.2.0 to 3.0.0 please note that you won't be able to see MAC Addresses and Brands because of a restriction of iOS 11.

  Features
+ Scans and finds available hosts in your network
+ Shows IP Address
+ Shows MAC Address (iOS 10 and below)
+ Shows Brand of device based on MAC Address (iOS 10 and below)
+ Shows hostname (if available)
+ Scan any subnet (not only /24)
+ Gives you the ability to update the OUI (MAC-Brand mappings) plist file. Check in MainPresenter.m for more details
                   DESC

  s.homepage         = 'https://github.com/mavris/MMLanScan'
  s.license          = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author           = { 'Michael Mavris' => 'info@miksoft.net' }
  s.source           = { :git => 'https://github.com/mavris/MMLanScan.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'MMLanScan/**/*.{h,m}'
  s.resources        = 'MMLanScan/Data/data.plist'
end
