//
//  SimplePing_withoutHost.h
//  MMLanScanDemo
//
//  Created by Jelle Alten on 10-06-17.
//  Copyright © 2017 Miksoft. All rights reserved.
//

#import "SimplePing.h"

@interface SimplePing(withoutHost)

+ (SimplePing*) simplePingWithIPAddress:(NSString*) ipAddress;
- (void)sendPingWithoutHostResolving;

@end
