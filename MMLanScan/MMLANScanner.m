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
@property (nonatomic,strong) NSDictionary *brandDictionary;
@end

//Ping interval
const float interval = 0.05;

@implementation MMLANScanner

#pragma mark - Initialization method
-(instancetype)initWithDelegate:(id<MMLANScannerDelegate>)delegate {

    self =[super init];
    
    if (self) {
        
        self.delegate=delegate;
        self.brandDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]];

    }
    
    return self;
}

#pragma mark - Start/Stop ping
-(void)start {

    self.dv = [LANProperties localIPAddress];
    
    if (!self.dv) {
        
        [self.delegate lanScanDidFailedToScan];
        return;
    }
    
    self.ipsToPing = [LANProperties getAllHostsForIP:self.dv.ipAddress andSubnet:self.dv.subnetMask];
    self.numOfHostsToPing = [self.ipsToPing count];
    self.currentHost=-1;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(pingAddress) userInfo:nil repeats:YES];
}

-(void)stop {
    if (self.timer) {
        [self.timer invalidate];
    }
}

#pragma mark - Ping method
-(void)pingAddress{
    
    self.currentHost++;
   
    [self.delegate lanScanProgressPinged:self.currentHost+1 from:self.numOfHostsToPing];
    
    NSString *address = self.ipsToPing[self.currentHost];
 
    [SimplePingHelper ping:address target:self sel:@selector(pingResult:) andCount:self.currentHost];
    
    if (self.currentHost==self.numOfHostsToPing-1) {
        
        [self.timer invalidate];
    }
}

#pragma mark - Ping Result callback
- (void)pingResult:(PingResult*)pr {
    
    
    Device *curDevice = [[Device alloc]init];
    curDevice.ipAddress=pr.ipAddress;
    curDevice.macAddress =[[MacFinder ip2mac:curDevice.ipAddress] uppercaseString];

    
    if (curDevice.macAddress || pr.success) {
        
        if (curDevice.macAddress) {

            curDevice.brand = [self.brandDictionary objectForKey:[[curDevice.macAddress substringWithRange:NSMakeRange(0, 8)] stringByReplacingOccurrencesOfString:@":" withString:@"-"]];
        }
        
        [self.delegate lanScanDidFindNewDevice:curDevice];
    }
    
    if (pr.ipCount==self.numOfHostsToPing-1) {
        
        [self.delegate lanScanDidFinishScanning];
    }
}

@end
