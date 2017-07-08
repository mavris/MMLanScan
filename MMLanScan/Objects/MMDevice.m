//
//  MMDevice.m
//  MMLanScanDemo
//
//  Created by Michalis Mavris on 08/07/2017.
//  Copyright © 2017 Miksoft. All rights reserved.
//

#import "MMDevice.h"

@implementation MMDevice
-(BOOL)isEqual:(id)object {
    return ([object isKindOfClass:[MMDevice class]] && [[object ipAddress] isEqualToString:_ipAddress]);
}


- (NSUInteger)hash {
    return [self.ipAddress hash];
}

-(NSString*)macAddressLabel {
    
    if (_macAddress) {
        return _macAddress;
    }
    
    return @"N/A";
}

-(NSString*)brand {
    
    if(_brand==nil || _brand == NULL || _brand==(id)[NSNull null]){
        return @"";
    }
    
    return _brand;
}

@end
