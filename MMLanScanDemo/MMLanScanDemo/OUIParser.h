//
//  OUIParser.h
//  MMLanScanDemo
//
//  Created by Michalis Mavris on 15/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OUIParser : NSObject
+(void)parseOUIWithSourceFilePath:(NSString*)sourceFilePath andOutputFilePath:(NSString*)outputFilePath;
@end
