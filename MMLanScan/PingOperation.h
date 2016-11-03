//
//  PingOperation.h
//  WhiteLabel-Test
//
//  Created by Michael Mavris on 03/11/2016.
//  Copyright © 2016 DW Dynamicworks Ltd. All rights reserved.
//

#import "PAOperation.h"
#import "SimplePing.h"

@interface PingOperation : PAOperation <SimplePingDelegate>
-(instancetype)initWithIPToPing:(nonnull NSString*)ip andCompletionHandler:(nullable void (^)(NSError  * _Nullable error, NSString  * _Nonnull ip))result;
@end
