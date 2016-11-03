//
//  PingOperation.m
//  WhiteLabel-Test
//
//  Created by Michael Mavris on 03/11/2016.
//  Copyright © 2016 DW Dynamicworks Ltd. All rights reserved.
//

#import "PingOperation.h"
#import "Device.h"
#import "LANProperties.h"
#import "MacFinder.h"

@interface PingOperation ()
@property (nonatomic,strong) NSString *ipStr;
@property (nonatomic,strong) NSDictionary *brandDictionary;
@property(nonatomic,strong)SimplePing *simplePing;
@property (nonatomic, copy) void (^result)(NSError  * _Nullable error, NSString  * _Nonnull ip);
@end

@implementation PingOperation {
    BOOL _stopRunLoop;
    NSTimer *_keepAliveTimer;
    NSError *errorMessage;
    NSTimer *pingTimer;
}

-(instancetype)initWithIPToPing:(NSString*)ip andCompletionHandler:(nullable void (^)(NSError  * _Nullable error, NSString  * _Nonnull ip))result;{

    self = [super init];
    
    if (self) {
        self.name = ip;
        self.ipStr= ip;
        self.simplePing = [SimplePing simplePingWithHostName:ip];
        self.simplePing.delegate = self;
        self.result = result;
    }
    
    return self;
};

-(void)start {

    [super start];
    // RUN LOOP MAGIC
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    // run loops don't run if they don't have input sources or timers on them.  So we add a timer that we never intend to fire.
    _keepAliveTimer = [NSTimer timerWithTimeInterval:1000000.0 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
    [runLoop addTimer:_keepAliveTimer forMode:NSDefaultRunLoopMode];
    
    [self ping];
    
    NSTimeInterval updateInterval = 0.1f;
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:updateInterval];
    while (!_stopRunLoop && [runLoop runMode: NSDefaultRunLoopMode beforeDate:loopUntil])
    {
        loopUntil = [NSDate dateWithTimeIntervalSinceNow:updateInterval];
    }

}
-(void)ping {

    [self.simplePing start];
}
- (void)finishedPing {
    
    // this removes (presumably still the only) timer from the NSRunLoop
    [_keepAliveTimer invalidate];
    _keepAliveTimer = nil;
    
    // and this will kill the while loop in the start method
    _stopRunLoop = YES;
    
    if (self.result) {
        self.result(errorMessage,self.name);
    }
    
    [self finish];
}

- (void)timeout:(NSTimer*)timer
{
    // this method should never get called.
    errorMessage = [NSError errorWithDomain:@"Ping Timeout" code:10 userInfo:nil];
    [self finishedPing];
}

-(void)cancel {
    
    [super cancel];
    [self finish];
}

#pragma mark - Pinger delegate

// When the pinger starts, send the ping immediately
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    [pinger sendPingWithData:nil];

    //NSLog(@"start");

}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
  //  NSLog(@"failed");
    [pingTimer invalidate];
    errorMessage = error;
    [self finishedPing];


}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error {
    //NSLog(@"failed");
    [pingTimer invalidate];
    errorMessage = error;
    [self finishedPing];


    // Eg they're not connected to any network
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet {
    //NSLog(@"success");
    [pingTimer invalidate];
    [self finishedPing];
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet {
    pingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
}

- (void)timerFired:(NSTimer *)timer {
    //NSLog(@"Ping timeout occurred, host not reachable");
    // Move to next host
    errorMessage = [NSError errorWithDomain:@"Ping timeout" code:11 userInfo:nil];
    [self finishedPing];
}

@end
