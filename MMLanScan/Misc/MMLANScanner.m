//
//  LANScanner.m
//
//  Created by Michalis Mavris on 05/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "LANProperties.h"
#import "PingOperation.h"
#import "MMLANScanner.h"
#import "MACOperation.h"
#import "MacFinder.h"
#import "Device.h"

@interface MMLANScanner ()
@property (nonatomic,strong) Device *device;
@property (nonatomic,strong) NSArray *ipsToPing;
@property (nonatomic,assign) float currentHost;
@property (nonatomic,strong) NSDictionary *brandDictionary;
@property (nonatomic,strong) NSOperationQueue *queue;
@property(nonatomic,assign,readwrite)BOOL isScanning;
@end

@implementation MMLANScanner {
    BOOL isFinished;
    BOOL isCancelled;
}

#pragma mark - Initialization method
-(instancetype)initWithDelegate:(id<MMLANScannerDelegate>)delegate {

    self = [super init];
    
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
        
        isFinished = NO;
        isCancelled = NO;
        self.isScanning = NO;
    }
    
    return self;
}

#pragma mark - Start/Stop ping
-(void)start {
    
    //In case the developer call start when is already running
    if (self.queue.operationCount!=0) {
        [self stop];
    }

    isFinished = NO;
    isCancelled = NO;
    self.isScanning = YES;

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
    
    //Looping through IPs array and adding the operations to the queue
    for (NSString *ipStr in self.ipsToPing) {
        
        //The ping operation
        PingOperation *pingOperation = [[PingOperation alloc]initWithIPToPing:ipStr andCompletionHandler:^(NSError  * _Nullable error, NSString  * _Nonnull ip) {
            if (!weakSelf) {
                return;
            }
            //Since the first half of the operation is completed we will update our proggress by 0.5
            weakSelf.currentHost = weakSelf.currentHost + 0.5;
            
        }];
        
        //The Find MAC Address for each operation
        MACOperation *macOperation = [[MACOperation alloc] initWithIPToRetrieveMAC:ipStr andBrandDictionary:self.brandDictionary andCompletionHandler:^(NSError * _Nullable error, NSString * _Nonnull ip, Device * _Nonnull device) {
            
            if (!weakSelf) {
                return;
            }
            
            //Since the second half of the operation is completed we will update our proggress by 0.5
            weakSelf.currentHost = weakSelf.currentHost + 0.5;

            if (!error) {
                
                //Letting know the delegate that found a new device (on Main Thread)
                dispatch_async (dispatch_get_main_queue(), ^{
                    if ([weakSelf.delegate respondsToSelector:@selector(lanScanDidFindNewDevice:)]) {
                        [weakSelf.delegate lanScanDidFindNewDevice:device];
                    }
                });
            }
            
            //Letting now the delegate the process  (on Main Thread)
            dispatch_async (dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(lanScanProgressPinged:from:)]) {
                    [weakSelf.delegate lanScanProgressPinged:self.currentHost from:[self.ipsToPing count]];
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
    
    isCancelled = YES;
    [self.queue cancelAllOperations];
    [self.queue waitUntilAllOperationsAreFinished];
    self.isScanning = NO;
}

#pragma mark - NSOperationQueue Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
   
    //Observing the NSOperationQueue and as soon as it finished we send a message to delegate
    if ([keyPath isEqualToString:@"operations"]) {
        
        if (self.queue.operationCount == 0 && isFinished == NO) {
            
            isFinished=YES;
            self.isScanning = NO;
            //Checks if is cancelled to sent the appropriate message to delegate
            MMLanScannerStatus currentStatus = isCancelled ? MMLanScannerStatusCancelled : MMLanScannerStatusFinished;
            
            //Letting know the delegate that the request is finished
            dispatch_async (dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(lanScanDidFinishScanningWithStatus:)]) {
                    [self.delegate lanScanDidFinishScanningWithStatus:currentStatus];
                }
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
