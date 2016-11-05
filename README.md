
MMLanScan
======

MMLanScan is an open source project for iOS that helps you scan your network and shows the available devices and their MAC Address.

### Screenshot
![image](LanScan.gif)

###Features
+ Scans and finds available hosts in your network
+ Shows IP Address
+ Shows MAC Address
+ Shows Brand of device based on MAC Address
+ Shows hostname (if available)
+ Scan any subnet (not only /24)
+ Gives you the ability to update the OUI (MAC-Brand mappings) plist file. Check in MainPresenter.m for more details

###Installation
- Drag n Drop the MMLanScan folder in your project.

###How to use it

Import MMLANScanner in your controller
```
#import "MMLANScanner.h"
```

Add the MMLANScannerDelegate (Protocol) to your controller
```
@interface YourViewController () <MMLANScannerDelegate>
```

Declare a property
```
@property(nonatomic,strong)MMLANScanner *lanScanner;
```

Initialize with delegate
```
self.lanScanner = [[MMLANScanner alloc] initWithDelegate:self];
```

Start the scan
```
[self.lanScanner start];
```

Implement the delegates methods to receive events
```
- (void)lanScanDidFindNewDevice:(Device*)device;
- (void)lanScanDidFinishScanningWithStatus:(MMLanScannerStatus)status;
- (void)lanScanProgressPinged:(NSInteger)pingedHosts from:(NSInteger)overallHosts;
- (void)lanScanDidFailedToScan;
```

###How it works
MMLanScan works like the classic network scanner. It first ping every host in the network in order to built the ARP table and then is trying to get the MAC Address for each host. If a MAC Address is found then it's considered that the host exist in the network.

###Libraries used to built MMLanScan
- Apples [SimplePing] (https://developer.apple.com/library/mac/samplecode/SimplePing/Introduction/Intro.html) 
- My [MacFinder] (https://github.com/mavris/MacFinder)

###Technical Stuff
MMLanScan V2.0 is now using NSOperation and NSOperationQueueManager. Scanning time, and UI interactions are improved compared to V1.0. Also V1.0 was ignoring hosts that didn't replied to pings. V2.0 is not and the result is now accurate.

###TODO
If anyone would like to help:
- ~~Convert the [OUI]~~ (https://standards.ieee.org/develop/regauth/oui/oui.txt) ~~text in a dictionary so we can map MAC Address with vendor (Hint: The Regex to catch the first line with MAC Address and vendor: ```[A-F0-9]{2}-[A-F0-9]{2}-[A-F0-9]{2}\s*\(hex\)\s*[A-Za-z\.\, \-]+```)~~
- ~~Make it work in a background thread. Apple's SimplePing has issues when it comes to GCD (it's built on C libraries and it seems their callbacks won't work with GCD)~~
- ~~Get hostname from IP address method is not working~~
- Anything that you feel that will improve this library.

###More Details

Visit my [article] (https://medium.com/rocknnull/ios-a-new-lan-network-scanner-library-has-been-born-f218f1a416a5#.sryxaq3b1) for MMLanScan for more details

###Authors
* Michael Mavris

###License

Copyright Miksoft 2016

Licensed under the MIT License
