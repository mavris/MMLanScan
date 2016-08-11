//
//  LANProperties.h
//
//  Created by Michalis Mavris on 05/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Device;

@interface LANProperties : NSObject
+(Device*)localIPAddress;
+(NSString *)getHostFromIPAddress:(NSString*)ipAddress;
+(NSArray*)getAllHostsForIP:(NSString*)ipAddress andSubnet:(NSString*)subnetMask;
+(NSString*)fetchSSIDInfo;
@end
