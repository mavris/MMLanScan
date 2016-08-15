//
//  OUIParser.m
//  MMLanScanDemo
//
//  Created by Michalis Mavris on 15/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "OUIParser.h"

@implementation OUIParser

+(void)parseOUIWithSourceFilePath:(NSString*)sourceFilePath andOutputFilePath:(NSString*)outputFilePath {

    NSError *error;
    
    NSString *sFilepath = sourceFilePath ? sourceFilePath : [[NSBundle mainBundle] pathForResource:@"oui" ofType:@"txt"];
  
    NSString *str = [NSString stringWithContentsOfFile:sFilepath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
     
        NSLog(@"Error reading file: %@", error.localizedDescription);
        return;
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[A-F0-9]{2}-[A-F0-9]{2}-[A-F0-9]{2}\\s*\\(hex\\)\\s*[A-Za-z\\.\\, \\-]+" options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (error) {
        
        NSLog(@"Error with RegEx: %@", error.localizedDescription);
        return;
    }
    
    
    NSArray *matches = [regex matchesInString:str options:0 range:NSMakeRange(0, [str length])];
    
    NSMutableDictionary *macDictionary = [[NSMutableDictionary alloc]init];
    
    for (NSTextCheckingResult *tcr in matches) {

        NSString *str2 =[str substringWithRange:tcr.range];
        NSString *mac = [str2 substringWithRange:NSMakeRange(0, 8)];
        NSString *company = [str2 substringWithRange:NSMakeRange(18, str2.length-18)];
        
        [macDictionary setObject:company forKey:mac];
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *oFilePath = outputFilePath ? outputFilePath : [documentsDirectory stringByAppendingPathComponent:@"data.plist"] ;
    
    BOOL wrote = [macDictionary writeToFile:oFilePath atomically:YES];
    
    NSString *result = wrote ? [NSString stringWithFormat:@"Successfull. You can find the plist at this path: %@",oFilePath]: @"Not successfull";
    NSLog(@"%@",result);
    
}
@end
