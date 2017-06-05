//
//  MainPresenter.m
//  MMLanScanDemo
//
//  Created by Michael Mavris on 04/11/2016.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "MainPresenter.h"
#import "LANProperties.h"
#import "MMLANScanner.h"
#import "MMDevice.h"
#include <arpa/inet.h>

@interface MainPresenter()<MMLANScannerDelegate>

@property (nonatomic,weak)id <MainPresenterDelegate> delegate;
@property(nonatomic,strong)MMLANScanner *lanScanner;
@property(nonatomic,assign,readwrite)BOOL isScanRunning;
@property(nonatomic,assign,readwrite)float progressValue;
@end

@implementation MainPresenter {
    NSMutableDictionary *connectedDevicesMutable;
}

#pragma mark - Init method
//Initialization with delegate
-(instancetype)initWithDelegate:(id <MainPresenterDelegate>)delegate {

    self = [super init];
    
    if (self) {
        
        self.isScanRunning=NO;
       
        self.delegate=delegate;
        
        self.lanScanner = [[MMLANScanner alloc] initWithDelegate:self];
    }
    
    return self;
}

#pragma mark - Button Actions
//This method is responsible for handling the tap button action on MainVC. In case the scan is running and the button is tapped it will stop the scan
-(void)scanButtonClicked {
    
    //Checks if is already scanning
    if (self.isScanRunning) {
        
        [self stopNetworkScan];
    }
    else {
        
        [self startNetworkScan];
    }
    
}
-(void)startNetworkScan {
    
    self.isScanRunning=YES;
    
    connectedDevicesMutable = [[NSMutableDictionary alloc] init];
    
    [self.lanScanner start];
};

-(void)stopNetworkScan {
    
    [self.lanScanner stop];
    
    self.isScanRunning=NO;
}

#pragma mark - SSID
//Getting the SSID string using LANProperties
-(NSString*)ssidName {

    return [NSString stringWithFormat:@"SSID: %@",[LANProperties fetchSSIDInfo]];
};

#pragma mark - MMLANScannerDelegate methods
//The delegate methods of MMLANScanner
-(void)lanScanDidFindNewDevice:(MMDevice*)device{

    connectedDevicesMutable[device.ipAddress] = device;

    //Updating the array that holds the data. MainVC will be notified by KVO
    self.connectedDevices = [[NSArray arrayWithArray:connectedDevicesMutable.allValues] sortedArrayUsingComparator:^NSComparisonResult(MMDevice*  _Nonnull obj1, MMDevice*  _Nonnull obj2) {

        return [self compareIP:obj1.ipAddress withIP:obj2.ipAddress];
    }];
}

- (NSComparisonResult) compareIP:(NSString*) ip1 withIP:(NSString*) ip2 {

    struct	in_addr sin_addr1;
    struct	in_addr sin_addr2;

    const char *ipCStr = [ip1 UTF8String];
    inet_pton(AF_INET, ipCStr, &sin_addr1);

    ipCStr = [ip2 UTF8String];
    inet_pton(AF_INET, ipCStr, &sin_addr2);

    if (sin_addr1.s_addr < sin_addr2.s_addr) {
        return NSOrderedAscending;
    } else if (sin_addr1.s_addr > sin_addr2.s_addr) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

-(void)lanScanDidFinishScanningWithStatus:(MMLanScannerStatus)status{
   
    self.isScanRunning=NO;
    
    //Checks the status of finished. Then call the appropriate method
    if (status == MMLanScannerStatusFinished) {
        
        [self.delegate mainPresenterIPSearchFinished];
    }
    else if (status==MMLanScannerStatusCancelled) {
       
        [self.delegate mainPresenterIPSearchCancelled];
    }
}

-(void)lanScanProgressPinged:(float)pingedHosts from:(NSInteger)overallHosts {
    
    //Updating the progress value. MainVC will be notified by KVO
    self.progressValue=pingedHosts/overallHosts;
}

-(void)lanScanDidFailedToScan {
   
    self.isScanRunning=NO;

    [self.delegate mainPresenterIPSearchFailed];
}

@end
