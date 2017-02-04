//
//  LANScanner.h
//
//  Created by Michalis Mavris on 05/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

typedef enum {
    MMLanScannerStatusFinished,
    MMLanScannerStatusCancelled
}
MMLanScannerStatus;

#import <Foundation/Foundation.h>

@class Device;
@protocol MMLANScannerDelegate;
#pragma mark - MMLANScanner Protocol
//The delegate protocol for MMLanScanner
@protocol MMLANScannerDelegate <NSObject>
@required
/*!
 @brief This delegate is called each time that MMLANSCanner discovers a new IP
 @param device The device object that contains the IP Address, MAC Address and hostname
 @code
 -(void)lanScanDidFindNewDevice:(Device*)device{
 
 //Check if the Device is already added
 if (![self.connectedDevices containsObject:device]) {
 
 [self.connectedDevices addObject:device];
 }
 }
 @endcode
 */
- (void)lanScanDidFindNewDevice:(Device*)device;

/*!
 @brief This delegate is called when the scan has finished
 
 @code
 -(void)lanScanDidFinishScanning{
 
 [[[UIAlertView alloc] initWithTitle:@"Scan Finished" message:[NSString stringWithFormat:@"Number of devices connected to the Local Area Network : %lu", (unsigned long)self.connectedDevices.count] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
 
 }
 @endcode
 */
- (void)lanScanDidFinishScanningWithStatus:(MMLanScannerStatus)status;

/*!
 @brief This delegate is called in case the LAN scan has failed
 */
- (void)lanScanDidFailedToScan;

@optional
/*!
 @brief This delegate is called each time a new host is pinged
 @param pingedHosts The number of hosts pinged so far
 @param overallHosts The number of all available hosts to ping
 @code
 - (void)lanScanProgressPinged:(NSInteger)pingedHosts from:(NSInteger)overallHosts {
 
 [self.progressView setProgress:(float)pingedHosts/overallHosts];
 }
 @endcode
 */
- (void)lanScanProgressPinged:(float)pingedHosts from:(NSInteger)overallHosts;

@end

#pragma mark - Public methods
@interface MMLANScanner : NSObject

@property(nonatomic,weak) id<MMLANScannerDelegate> delegate;
/*!
 @brief Custom init method. Always use this method to initialize MMLANScanner
 @param delegate The object that will receive the messages from MMLANScanner
 @code
 self.lanScanner = [[MMLANScanner alloc] initWithDelegate:self];
 @endcode
 */
-(instancetype)initWithDelegate:(id <MMLANScannerDelegate>)delegate;
/*!
 @brief A bool property that lets you know when the MMLANScanner is scanning. KVO compliant
 */
@property(nonatomic,assign,readonly)BOOL isScanning;

/*!
 @brief Starts the scanning
 */
- (void)start;
/*!
 @brief Stops the scanning
 */
- (void)stop;
@end
