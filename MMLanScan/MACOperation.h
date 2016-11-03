//
//  PingOperation.h
//
//  Created by Michael Mavris on 03/11/2016.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "PAOperation.h"
#import "SimplePing.h"
@class Device;
@interface MACOperation: PAOperation
-(instancetype)initWithIPToPing:(nonnull NSString*)ip andCompletionHandler:(nullable void (^)(NSError  * _Nullable error, NSString  * _Nonnull ip,Device * _Nonnull device))result;
@end
