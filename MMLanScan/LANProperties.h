//
//  LANProperties.h
//
//  Created by Michalis Mavris on 05/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Device;

@interface LANProperties : NSObject

/*!
 @brief This method returns the Local IP Address and MAC Address as Device object
 @return The device object
 @code
 Device *newDevice = [LANProperties localIPAddress];
 @endcode
 */
+(Device*)localIPAddress;

/*!
 @brief This method returns the hostname of a specific IP Address
 @param ipAddress The IP Address in string
 @return An NSString which is the host of the IP Address
 @code
 NSString *newDevice = [LANProperties getHostFromIPAddress:@"192.168.1.10"];
 @endcode
 */
+(NSString *)getHostFromIPAddress:(NSString*)ipAddress;

/*!
 @brief This method returns an array of the hosts that are available for ping (eg. /24 has 254 hosts etc)
 @param ipAddress The IP Address in string
 @param subnetMask The subnet mask in string
 @return An array that holds all the available hosts to ping
 @code
 NSArray *hostsArray = [LANProperties getAllHostsForIP:@"192.168.1.10" andSubnet:@"255.255.255.0"];
 @endcode
 */
+(NSArray*)getAllHostsForIP:(NSString*)ipAddress andSubnet:(NSString*)subnetMask;

/*!
 @brief This method returns the SSID of the WiFi if is available, otherwise returns "No WiFi available"
 @return An NSString which is the SSID of the WiFi network
 @code
 NSString *wifiSSID = [LANProperties fetchSSIDInfo];
 @endcode
 */
+(NSString*)fetchSSIDInfo;
@end
