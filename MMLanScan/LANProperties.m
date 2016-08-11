//
//  LANProperties.m
//
//  Created by Michalis Mavris on 05/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "LANProperties.h"
#import "Device.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <netdb.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "NetworkCalculator.h"

@implementation LANProperties

#pragma mark - Public methods
+(Device*)localIPAddress {
    
    Device *localDevice = [[Device alloc]init];
    
    localDevice.ipAddress = @"error";
    
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    
    if (success == 0) {
        
        temp_addr = interfaces;
        
        while(temp_addr != NULL) {
            
            // check if interface is en0 which is the wifi connection on the iPhone
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    
                    localDevice.ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    localDevice.subnetMask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                    localDevice.hostname = [self getHostFromIPAddress:localDevice.ipAddress];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    //In case we failed to fetch IP address
    if ([localDevice.ipAddress isEqualToString:@"error"]) {
        
        return nil;
    }
    
    return localDevice;
}

+(NSString*)fetchSSIDInfo {
    
    NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();

    NSDictionary *info;
    
    for (NSString *ifnam in ifs) {
        
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        if (info && [info count]) {
    
            return [info objectForKey:@"SSID"];
            break;
        }
    }
    
    return @"No WiFi Available";
}
//Getting all the hosts to ping and returns them as array
+(NSArray*)getAllHostsForIP:(NSString*)ipAddress andSubnet:(NSString*)subnetMask {
    
    return [NetworkCalculator getAllHostsForIP:ipAddress andSubnet:subnetMask];
}

//Not working
#pragma mark - Get Host from IP
+(NSString *)getHostFromIPAddress:(NSString*)ipAddress {
    
    NSString *nsHostName = nil;

    const char *charIPAddress = [ipAddress UTF8String];
    
    struct addrinfo *results = NULL;
    
    char hostname[NI_MAXHOST] = {0};

    if ( getaddrinfo(charIPAddress, NULL, NULL, &results) != 0 )
        
        return nil;
    
    for (struct addrinfo *r = results; r; r = r->ai_next) {
        
        if (getnameinfo(r->ai_addr, r->ai_addrlen, hostname, sizeof hostname, NULL, 0 , 0) != 0)
            
            continue;
        else {
            
            nsHostName = [NSString stringWithFormat:@"%s", hostname];
            break;
        }
    }
    
    freeaddrinfo(results);
    
    return nsHostName;
}

@end
