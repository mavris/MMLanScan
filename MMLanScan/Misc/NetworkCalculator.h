//
//  NetworkCalculator.h
//  MMLanScanDemo
//
//  Created by Michalis Mavris on 12/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkCalculator : NSObject
+(NSArray*)getAllHostsForIP:(NSString*)ipAddress andSubnet:(NSString*)subnetMask;
@end
