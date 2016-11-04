//
//  MainVC.m
//  MMLanScan
//
//  Created by Michalis Mavris on 11/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "MainVC.h"
#import "MainPresenter.h"
#import "DeviceCell.h"
#import "Device.h"
//#import "OUIParser.h"
@interface MainVC () <UITableViewDataSource,UITableViewDelegate,MainPresenterDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBarTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableVTopContraint;
@property (strong, nonatomic) MainPresenter *presenter;
@end

@implementation MainVC {
    BOOL isScanning;
}

- (void)viewDidLoad {
   
    [super viewDidLoad];
    
    self.presenter = [[MainPresenter alloc]initWithDelegate:self];
    
    //This is not a production code. Run this command only if you have a new OUI.txt file to parse. After parsing the default location of data.plist will be on DocumentsDirectory. Then you can add the new data.plist to your project and build it.
    //[OUIParser parseOUIWithSourceFilePath:nil andOutputFilePath:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [self.navigationBarTitle setTitle:[self.presenter ssidName]];
}

- (IBAction)refresh:(id)sender {
    
    [self startScanning];
}

-(void)startScanning {

    [self showProgressBar];
    
    [self.navigationBarTitle setTitle:[self.presenter ssidName]];
    
    [self.presenter startNetworkScan];
    
    [self.tableV reloadData];
    
}

-(void)showProgressBar {

    [self.progressView setProgress:0.0];

    [UIView animateWithDuration:0.5 animations:^{
        
        self.tableVTopContraint.constant=40;
        [self.view layoutIfNeeded];
    }];
}

-(void)hideProgressBar {
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.tableVTopContraint.constant=0;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Presenter Delegates
-(void)mainPresenterIPArrayChanged{

    [self.tableV reloadData];
};

-(void)mainPresenterIPSearchFinished {
    
    [[[UIAlertView alloc] initWithTitle:@"Scan Finished" message:[NSString stringWithFormat:@"Number of devices connected to the Local Area Network : %lu", (unsigned long)self.presenter.connectedDevices.count] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    [self hideProgressBar];
};

-(void)mainPresenterUpdateProgressBarWithValue:(float)progressValue {

    [self.progressView setProgress:progressValue];
};

-(void)mainPresenterIPSearchFailed {
    
    [[[UIAlertView alloc] initWithTitle:@"Failed to scan" message:[NSString stringWithFormat:@"Please make sure that you are connected to a WiFi before starting LAN Scan"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
};

#pragma mark - UITableView Delegates
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    return [self.presenter.connectedDevices count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *tableIdentifier = @"DeviceCell";
    
    DeviceCell *cell = (DeviceCell*)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    if (cell == nil) {
        cell = [[DeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    Device *nd = [self.presenter.connectedDevices objectAtIndex:indexPath.row];
    
    cell.ipLabel.text = nd.ipAddress;
    cell.macAddressLabel.text = nd.macAddress;
    cell.brandLabel.text = nd.brand;
    cell.hostnameLabel.text= nd.hostname;
    
    return cell;
}

@end
