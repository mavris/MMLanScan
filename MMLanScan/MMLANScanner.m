//
//  LANScanner.m
//
//  Created by Michalis Mavris on 05/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "MMLANScanner.h"
#import "Device.h"
#import "LANProperties.h"
#import "SimplePingHelper.h"
#import "MacFinder.h"
#import "PingResult.h"


@interface MMLANScanner ()
@property (nonatomic,strong) Device *dv;
@property (nonatomic,strong) NSArray *ipsToPing;
@property (nonatomic,assign) NSInteger numOfHostsToPing;
@property (nonatomic,assign) NSInteger currentHost;
@property (nonatomic,strong) NSTimer *timer;

@end

@implementation MMLANScanner

-(instancetype)initWithDelegate:(id<MMLANScannerDelegate>)delegate {

    self =[super init];
    
    if (self) {
        
        self.delegate=delegate;
    }
    
    return self;
}
-(void)start {

    self.dv = [LANProperties localIPAddress];
    
    if (!self.dv) {
        [self.delegate lanScanDidFailedToScan];
        return;
    }
    
    self.ipsToPing = [LANProperties getAllHostsForIP:self.dv.ipAddress andSubnet:self.dv.subnetMask];
    self.numOfHostsToPing = [self.ipsToPing count];
    self.currentHost=-1;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(pingAddress) userInfo:nil repeats:YES];
}

-(void)pingAddress{
    self.currentHost++;
   
    [self.delegate lanScanProgressPinged:self.currentHost+1 from:self.numOfHostsToPing];
    
    NSString *address = self.ipsToPing[self.currentHost];
 
    [SimplePingHelper ping:address target:self sel:@selector(pingResult:) andCount:self.currentHost];
    
    if (self.currentHost==self.numOfHostsToPing-1) {
        [self.timer invalidate];
    }
}

- (void)pingResult:(PingResult*)pr {
    
    
    Device *curDevice = [[Device alloc]init];

    curDevice.ipAddress=pr.ipAddress;
    curDevice.macAddress =[[MacFinder ip2mac:curDevice.ipAddress] uppercaseString];

    
    if (curDevice.macAddress || pr.success) {
        
        [self.delegate lanScanDidFindNewAddressWithIP:curDevice.ipAddress MACAddress:curDevice.macAddressLabel andHostname:@""];
    }
    
    if (pr.ipCount==self.numOfHostsToPing-1) {
        
        [self.delegate lanScanDidFinishScanning];
    }
}


-(void)stop {
    if (self.timer) {
        [self.timer invalidate];
    }
}
@end
