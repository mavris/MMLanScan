//
//  PingOperation.m
//
//  Created by Michael Mavris on 03/11/2016.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "MACOperation.h"
#import "Device.h"
#import "LANProperties.h"
#import "MacFinder.h"

@interface MACOperation ()
@property (nonatomic,strong) NSString *ipStr;
@property (nonatomic, copy) void (^result)(NSError  * _Nullable error, NSString  * _Nonnull ip,Device * _Nonnull device);
@property(nonnull,strong)Device *device;
@end

@implementation MACOperation {

    NSError *errorMessage;
}

-(instancetype)initWithIPToRetrieveMAC:(NSString*)ip andCompletionHandler:(nullable void (^)(NSError  * _Nullable error, NSString  * _Nonnull ip,Device * _Nonnull device))result;{

    self = [super init];
    
    if (self) {
        self.device = [[Device alloc]init];
        self.name = ip;
        self.ipStr= ip;
        self.result = result;
    }
    
    return self;
};

-(void)start {

    [super start];
    [self getMACDetails];
}
-(void)finishMAC {
   
    if (self.result) {
        self.result(errorMessage,self.name,self.device);

    [self finish];
}
}
-(void)cancel{
    [super cancel];
    [self finish];
}
    
#pragma mark - Ping Result callback
-(void)getMACDetails{
    
    self.device.ipAddress=self.ipStr;
    self.device.macAddress =[[MacFinder ip2mac:self.device.ipAddress] uppercaseString];
    self.device.hostname = [LANProperties getHostFromIPAddress:self.ipStr];
    
    if (!self.device.macAddress) {
 
        errorMessage = [NSError errorWithDomain:@"MAC Address Not Exist" code:10 userInfo:nil];
    }

    [self finishMAC];
}

@end
