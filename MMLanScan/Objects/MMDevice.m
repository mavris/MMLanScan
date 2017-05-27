//
//  MMDevice.m
//
//  Created by Michalis Mavris on 06/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
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
