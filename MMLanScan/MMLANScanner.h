//
//  LANScanner.h
//
//  Created by Michalis Mavris on 05/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMLANScannerDelegate <NSObject>

@optional
- (void)lanScanDidFindNewAddressWithIP:(NSString*)ipAddress MACAddress:(NSString*)macAddress andHostname:(NSString*)hostname;
- (void)lanScanDidFinishScanning;
- (void)lanScanProgressPinged:(NSInteger)pingedHosts from:(NSInteger)overallHosts;
- (void)lanScanDidFailedToScan;

@end

@interface MMLANScanner : NSObject <MMLANScannerDelegate>
@property(nonatomic,weak) id<MMLANScannerDelegate> delegate;
-(instancetype)initWithDelegate:(id <MMLANScannerDelegate>)delegate;
- (void)start;
- (void)stop;
@end
