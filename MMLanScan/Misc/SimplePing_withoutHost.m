//
//  SimplePing_withoutHost.m
//  MMLanScanDemo
//
//  Created by Jelle Alten on 10-06-17.
//  Copyright © 2017 Miksoft. All rights reserved.
//

#import "SimplePing_withoutHost.h"

#include <arpa/inet.h>

@interface SimplePing()

- (void) setHostAddress:(NSData*) address;
- (void)startWithHostAddress;

@end

@implementation SimplePing(withoutHost)

+ (SimplePing*) simplePingWithIPAddress:(NSString*) ipAddress {

    NSData* addrData = [self addrDataFromIP:ipAddress];
    return [[SimplePing alloc] initWithAddress:addrData];
}

+ (NSData *)addrDataFromIP:(NSString*) ipStr {
    struct sockaddr_in remoteAddr;
    remoteAddr.sin_len = sizeof(remoteAddr);
    remoteAddr.sin_family = AF_INET;
    remoteAddr.sin_port = htons(161);
    const char *ipCStr = [ipStr UTF8String];
    inet_pton(AF_INET, ipCStr, &remoteAddr.sin_addr);

    return [NSData dataWithBytes:&remoteAddr length:remoteAddr.sin_len];
}


- (instancetype) initWithAddress:(NSData*) address {

    if (self = [self initWithHostName:@""] ) {

        [self setAddress:address];
        return self;
    } else {

        return nil;
    }
}

- (void)sendPingWithoutHostResolving {

    [self startWithHostAddress];
}


- (void) setAddress:(NSData*) address {

    const struct sockaddr * addrPtr;

    addrPtr = (const struct sockaddr *) address.bytes;
    if ( address.length >= sizeof(struct sockaddr) ) {
        switch (addrPtr->sa_family) {
            case AF_INET: {
                if (self.addressStyle != SimplePingAddressStyleICMPv6) {

                    if ([self respondsToSelector:@selector(setHostAddress:)]) {

                        [(id)self setHostAddress:address];
                    }
                }
            } break;
            case AF_INET6: {
                if (self.addressStyle != SimplePingAddressStyleICMPv4) {

                    if ([self respondsToSelector:@selector(setHostAddress:)]) {

                        [(id)self setHostAddress:address];
                    }
                }
            } break;
        }
    }
}

@end
