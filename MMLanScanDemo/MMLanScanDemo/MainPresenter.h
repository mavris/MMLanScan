//
//  MainPresenter.h
//  MMLanScanDemo
//
//  Created by Michael Mavris on 04/11/2016.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol  MainPresenterDelegate
-(void)mainPresenterIPArrayChanged;
-(void)mainPresenterIPSearchFinished;
-(void)mainPresenterIPSearchFailed;
-(void)mainPresenterUpdateProgressBarWithValue:(float)progressValue;
@end

@interface MainPresenter : NSObject
-(instancetype)initWithDelegate:(id <MainPresenterDelegate>)delegate;
-(void)startNetworkScan;
-(NSString*)ssidName;
@property NSMutableArray *connectedDevices;
@end
