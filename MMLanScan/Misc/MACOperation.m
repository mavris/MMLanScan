//
//  PingOperation.m
//
//  Created by Michael Mavris on 03/11/2016.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "MACOperation.h"
#import "LANProperties.h"
#import "MacFinder.h"
#import "Device.h"

@interface MACOperation ()
@property (nonatomic,strong) NSString *ipStr;
@property (nonatomic, copy) void (^result)(NSError  * _Nullable error, NSString  * _Nonnull ip,Device * _Nonnull device);
@property(nonatomic,strong)Device *device;
@property(nonatomic,weak)NSDictionary *brandDictionary;
@end

@interface MACOperation()
- (void)finish;
@end

@implementation MACOperation {

    NSError *errorMessage;
}

-(instancetype)initWithIPToRetrieveMAC:(NSString*)ip andBrandDictionary:(NSDictionary*)brandDictionary andCompletionHandler:(nullable void (^)(NSError  * _Nullable error, NSString  * _Nonnull ip,Device * _Nonnull device))result;{

    self = [super init];
    
    if (self) {
        
        self.device = [[Device alloc]init];
        self.name = ip;
        self.ipStr= ip;
        self.result = result;
        self.brandDictionary=brandDictionary;
        _isExecuting = NO;
        _isFinished = NO;

    }
    
    return self;
};

-(void)start {

    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        _isFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];

    [self getMACDetails];
}
-(void)finishMAC {
   
    if (self.isCancelled) {
        [self finish];
        return;
    }
    
    if (self.result) {
        self.result(errorMessage,self.name,self.device);
    }

    [self finish];
}

-(void)finish {
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
}

- (BOOL)isExecuting {
    return _isExecuting;
}

- (BOOL)isFinished {
    return _isFinished;
}

#pragma mark - Ping Result callback
-(void)getMACDetails{
    
    self.device.ipAddress=self.ipStr;
    self.device.macAddress =[[MacFinder ip2mac:self.device.ipAddress] uppercaseString];
    self.device.hostname = [LANProperties getHostFromIPAddress:self.ipStr];
    
    if (!self.device.macAddress) {
 
        errorMessage = [NSError errorWithDomain:@"MAC Address Not Exist" code:10 userInfo:nil];
    }
    else {
        //Retrieving brand for the specific MAC Address
        self.device.brand = [self.brandDictionary objectForKey:[[self.device.macAddress substringWithRange:NSMakeRange(0, 8)] stringByReplacingOccurrencesOfString:@":" withString:@"-"]];
    }

    [self finishMAC];
}

@end
