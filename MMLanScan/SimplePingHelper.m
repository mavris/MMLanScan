//
//  SimplePingHelper.m
//  PingTester
//
//  Created by Chris Hulbert on 18/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SimplePingHelper.h"
#import "PingResult.h"

@interface SimplePingHelper()
@property(nonatomic,retain) SimplePing* simplePing;
@property(nonatomic,retain) id target;
@property(nonatomic,assign) SEL sel;
@property(nonatomic,strong) NSString *ipAddress;
@property(nonatomic,assign) NSInteger pingCount;
- (id)initWithAddress:(NSString*)address target:(id)_target sel:(SEL)_sel andCount:(NSInteger)pingCount;
- (void)go;
@end

@implementation SimplePingHelper
@synthesize simplePing, target, sel;

#pragma mark - Run it

// Pings the address, and calls the selector when done. Selector must take a NSnumber which is a bool for success
+ (void)ping:(NSString*)address target:(id)target sel:(SEL)sel andCount:(NSInteger)pingCount{
	// The helper retains itself through the timeout function
	[[[SimplePingHelper alloc] initWithAddress:address target:target sel:sel andCount:pingCount] go];
}

#pragma mark - Init/dealloc
- (void)dealloc {
	self.simplePing = nil;
	self.target = nil;
}

- (id)initWithAddress:(NSString*)address target:(id)_target sel:(SEL)_sel andCount:(NSInteger)pingCount {
	
    if (self = [self init]) {
	
        self.simplePing = [SimplePing simplePingWithHostName:address];
		self.simplePing.delegate = self;
		self.target = _target;
		self.sel = _sel;
        self.ipAddress = address;
        self.pingCount = pingCount;
	}
    
	return self;
}

#pragma mark - Go

- (void)go {
	
    [self.simplePing start];
	[self performSelector:@selector(endTime) withObject:nil afterDelay:1]; // This timeout is what retains the ping helper
}

#pragma mark - Finishing and timing out

// Called on success or failure to clean up
- (void)killPing {
	
    [self.simplePing stop];
	self.simplePing = nil;
}

- (void)successPing {
	
    [self killPing];
    
    PingResult *pr = [[PingResult alloc]init];
    
    [pr setIpAddress:self.ipAddress];
    [pr setIpCount:self.pingCount];
    [pr setSuccess:YES];
    
    [target performSelector:sel withObject:pr afterDelay:0];
}

- (void)failPing:(NSString*)reason {
	
    [self killPing];
    
    PingResult *pr = [[PingResult alloc]init];
    
    [pr setIpAddress:self.ipAddress];
    [pr setSuccess:NO];
    [pr setIpCount:self.pingCount];
    
    [target performSelector:sel withObject:pr afterDelay:0];

}

// Called 1s after ping start, to check if it timed out
- (void)endTime {
	
    if (self.simplePing) { // If it hasn't already been killed, then it's timed out
		
        [self failPing:@"timeout"];
	}
}

#pragma mark - Pinger delegate

// When the pinger starts, send the ping immediately
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
	
    [self.simplePing sendPingWithData:nil];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
	
    [self failPing:@"didFailWithError"];
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error {
	
    // Eg they're not connected to any network
	[self failPing:@"didFailToSendPacket"];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet {
	
    [self successPing];
}

@end
