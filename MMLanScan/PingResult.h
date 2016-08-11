//
//  PingResult.h
//
//  Created by Michalis Mavris on 06/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PingResult : NSObject
@property(nonatomic,strong)NSString *ipAddress;
@property(nonatomic,assign)NSInteger ipCount;
@property(nonatomic,assign)BOOL success;

@end
