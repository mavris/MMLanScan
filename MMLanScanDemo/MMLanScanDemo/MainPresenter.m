//
//  MainPresenter.m
//  MMLanScanDemo
//
//  Created by Michael Mavris on 04/11/2016.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "MainPresenter.h"
#import "Device.h"
#import "LANProperties.h"
#import "MMLANScanner.h"

@interface MainPresenter()<MMLANScannerDelegate>

@property (nonatomic,weak)id <MainPresenterDelegate> delegate;
@property(nonatomic,strong)MMLANScanner *lanScanner;
@end

@implementation MainPresenter

-(instancetype)initWithDelegate:(id <MainPresenterDelegate>)delegate {

    self = [super init];
    
    if (self) {
    
        self.delegate=delegate;
        self.lanScanner = [[MMLANScanner alloc] initWithDelegate:self];
    }
    
    return self;
}

-(void)startNetworkScan {
    [self.lanScanner stop];
    self.connectedDevices = [[NSMutableArray alloc] init];
    [self.lanScanner start];

};

-(NSString*)ssidName {

    return [NSString stringWithFormat:@"SSID: %@",[LANProperties fetchSSIDInfo]];
};

#pragma mark LAN Scanner delegate method
-(void)lanScanDidFindNewDevice:(Device*)device{
    
    //Check if the Device is already added
    if (![self.connectedDevices containsObject:device]) {

        [self.connectedDevices addObject:device];
    }
    
    [self.delegate mainPresenterIPArrayChanged];
}

-(void)lanScanDidFinishScanning{
    
    [self.delegate mainPresenterIPSearchFinished];
    
}

-(void)lanScanProgressPinged:(float)pingedHosts from:(NSInteger)overallHosts {
    
    [self.delegate mainPresenterUpdateProgressBarWithValue:pingedHosts/overallHosts];
    
}

-(void)lanScanDidFailedToScan {
    
    [self.delegate mainPresenterIPSearchFailed];
}

@end
