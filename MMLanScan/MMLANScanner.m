//
//  LANScanner.m
//
//  Created by Michalis Mavris on 05/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "MMLANScanner.h"
#import "Device.h"
#import "LANProperties.h"
#import "MacFinder.h"
#import "PingOperation.h"
#import "MACOperation.h"

@interface MMLANScanner ()
@property (nonatomic,strong) Device *dv;
@property (nonatomic,strong) NSArray *ipsToPing;
@property (nonatomic,assign) NSInteger numOfHostsToPing;
@property (nonatomic,assign) float currentHost;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSDictionary *brandDictionary;
@property(nonatomic,strong)NSOperationQueue *queue;
@end

//Ping interval
const float interval = 0.1;

@implementation MMLANScanner

#pragma mark - Initialization method
-(instancetype)initWithDelegate:(id<MMLANScannerDelegate>)delegate {

    self =[super init];
    
    if (self) {
        
        self.delegate=delegate;
        self.brandDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]];
        self.queue = [[NSOperationQueue alloc] init];
        [self.queue setMaxConcurrentOperationCount:50];
        [self.queue addObserver:self forKeyPath:@"operations" options:0 context:nil];

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

    MMLANScanner * __weak weakSelf = self;

    self.currentHost=0;
    for (NSString *str in self.ipsToPing) {
        MMLANScanner* __strong strongSelf = weakSelf;
        
        PingOperation *po = [[PingOperation alloc]initWithIPToPing:str andCompletionHandler:^(NSError  * _Nullable error, NSString  * _Nonnull ip) {
            
            MACOperation *macOp = [[MACOperation alloc] initWithIPToPing:ip andCompletionHandler:^(NSError * _Nullable error, NSString * _Nonnull ip, Device * _Nonnull device) {
                
                self.currentHost = self.currentHost + 0.5;
               
                if (!error) {
                    device.brand = [self.brandDictionary objectForKey:[[device.macAddress substringWithRange:NSMakeRange(0, 8)] stringByReplacingOccurrencesOfString:@":" withString:@"-"]];
                    
                    dispatch_async (dispatch_get_main_queue(), ^{
                        [strongSelf.delegate lanScanDidFindNewDevice:device];
                    });
                    NSLog(@"Succeed for IP:%@ MAC:%@",ip,device.macAddress);
                }
                
                dispatch_async (dispatch_get_main_queue(), ^{
                    [strongSelf.delegate lanScanProgressPinged:self.currentHost from:[self.ipsToPing count]];
                });
            }];
            
            self.currentHost = self.currentHost + 0.5;
            dispatch_async (dispatch_get_main_queue(), ^{
                [strongSelf.delegate lanScanProgressPinged:self.currentHost from:[self.ipsToPing count]];
            });
           
            if (!error) {
                NSLog(@"Succeed for IP:%@",ip);
            }

            [strongSelf.queue addOperation:macOp];
            
        }];
        
        [self.queue addOperation:po];
        
    }

}

-(void)stop {
    [self.queue cancelAllOperations];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"operations"]) {
        if (self.queue.operationCount == 0) {
            
            dispatch_async (dispatch_get_main_queue(), ^{
                [self.delegate lanScanDidFinishScanning];
            });
            
        } else {
            // NSLog(@"Remaining %lu",(unsigned long)[qm operationCount]);
            // Has ops
        }
    }
}
-(void)dealloc {
    [self.queue removeObserver:self forKeyPath:@"operations"];
}
@end
