//
//  MainPresenter.h
//  MMLanScanDemo
//
//  Created by Michael Mavris on 04/11/2016.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol  MainPresenterDelegate
-(void)mainPresenterIPSearchFinished;
-(void)mainPresenterIPSearchCancelled;
-(void)mainPresenterIPSearchFailed;
@end

@interface MainPresenter : NSObject
@property(nonatomic,strong)NSArray *connectedDevices;
@property(nonatomic,assign,readonly)float progressValue;
@property(nonatomic,assign,readonly)BOOL isScanRunning;
-(instancetype)initWithDelegate:(id <MainPresenterDelegate>)delegate;
-(void)scanButtonClicked;
-(NSString*)ssidName;
@end
