//
//  MMDevice.h
//
//  Created by Michalis Mavris on 06/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMDevice : NSObject

@property (nonatomic,strong) NSString *hostname;
@property (nonatomic,strong) NSString *ipAddress;
@property (nonatomic,strong) NSString *macAddress;
@property (nonatomic,strong) NSString *subnetMask;
@property (nonatomic,strong) NSString *brand;

-(NSString*)macAddressLabel;
@end
