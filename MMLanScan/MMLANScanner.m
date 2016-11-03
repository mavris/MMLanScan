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
@property (nonatomic,strong) Device *device;
@property (nonatomic,strong) NSArray *ipsToPing;
@property (nonatomic,assign) float currentHost;
@property (nonatomic,strong) NSDictionary *brandDictionary;
@property (nonatomic,strong) NSOperationQueue *queue;
@end

@implementation MMLANScanner

#pragma mark - Initialization method
-(instancetype)initWithDelegate:(id<MMLANScannerDelegate>)delegate {

    self =[super init];
    
    if (self) {
        
        //Setting the delegate
        self.delegate=delegate;
        
        //Initializing the dictionary that holds the Brands name for each MAC Address
        self.brandDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]];
        
        //Initializing the NSOperationQueue
        self.queue = [[NSOperationQueue alloc] init];
        //Setting the concurrent operations to 50
        [self.queue setMaxConcurrentOperationCount:50];
        //Add observer to notify the delegate when queue is empty.
        [self.queue addObserver:self forKeyPath:@"operations" options:0 context:nil];

    }
    
    return self;
}

#pragma mark - Start/Stop ping
-(void)start {
    //Getting the local IP
    self.device = [LANProperties localIPAddress];
    
    //If IP is null then return
    if (!self.device) {
        [self.delegate lanScanDidFailedToScan];
        return;
    }
    
    //Getting the available IPs to ping based on our network subnet.
    self.ipsToPing = [LANProperties getAllHostsForIP:self.device.ipAddress andSubnet:self.device.subnetMask];

    //The counter of how much pings have been made
    self.currentHost=0;

    //Making a weak reference to self in order to use it from the completionBlocks in operation.
    MMLANScanner * __weak weakSelf = self;
    
    //Looping through IPs array
    for (NSString *ipStr in self.ipsToPing) {
        
        //Making a strong reference in the weakSelf to make sure that it won't be nil at the time of the execution of the block
        MMLANScanner* __strong strongSelf = weakSelf;
        
        //The ping operation
        PingOperation *pingOperation = [[PingOperation alloc]initWithIPToPing:ipStr andCompletionHandler:^(NSError  * _Nullable error, NSString  * _Nonnull ip) {
            
            //Since the first half of the operation is completed we will update our proggress by 0.5
            self.currentHost = self.currentHost + 0.5;

            //Letting now the delegate the process
            dispatch_async (dispatch_get_main_queue(), ^{
                if ([strongSelf.delegate respondsToSelector:@selector(lanScanProgressPinged:from:)]) {
                    [strongSelf.delegate lanScanProgressPinged:self.currentHost from:[self.ipsToPing count]];
                }
            });
            
        }];
        
        //The Find MAC Address for each operation
        MACOperation *macOperation = [[MACOperation alloc] initWithIPToRetrieveMAC:ipStr andCompletionHandler:^(NSError * _Nullable error, NSString * _Nonnull ip, Device * _Nonnull device) {
            
            //Since the second half of the operation is completed we will update our proggress by 0.5
            self.currentHost = self.currentHost + 0.5;
            
            if (!error) {
                //Retrieving brand for the specific MAC Address
                device.brand = [strongSelf.brandDictionary objectForKey:[[device.macAddress substringWithRange:NSMakeRange(0, 8)] stringByReplacingOccurrencesOfString:@":" withString:@"-"]];
                
                //Letting know the delegate that found a new device (on Main Thread)
                dispatch_async (dispatch_get_main_queue(), ^{
                    if ([strongSelf.delegate respondsToSelector:@selector(lanScanDidFindNewDevice:)]) {
                        [strongSelf.delegate lanScanDidFindNewDevice:device];
                    }
                });
            }
            
            //Letting now the delegate the process
            dispatch_async (dispatch_get_main_queue(), ^{
                if ([strongSelf.delegate respondsToSelector:@selector(lanScanProgressPinged:from:)]) {
                    [strongSelf.delegate lanScanProgressPinged:self.currentHost from:[self.ipsToPing count]];
                }
            });
        }];

        //Adding dependancy on macOperation. For each IP there 2 operations (macOperation and pingOperation). The dependancy makes sure that macOperation will run after pingOperation
        [macOperation addDependency:pingOperation];
        //Adding the operations in the queue
        [self.queue addOperation:pingOperation];
        [self.queue addOperation:macOperation];
        
    }

}

-(void)stop {
    [self.queue cancelAllOperations];
}

#pragma mark - NSOperationQueue Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
   
    //Observing the NSOperationQueue and as soon as it finished we send a message to delegate
    if ([keyPath isEqualToString:@"operations"]) {
        
        if (self.queue.operationCount == 0) {
            //Letting know the delegate that the request is finished
            dispatch_async (dispatch_get_main_queue(), ^{
                [self.delegate lanScanDidFinishScanning];
            });
        }
    }
}
#pragma mark - Dealloc
-(void)dealloc {
    
    //Removing the observer on dealloc
    [self.queue removeObserver:self forKeyPath:@"operations"];
}
@end
