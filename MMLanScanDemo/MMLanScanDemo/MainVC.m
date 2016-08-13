//
//  MainVC.m
//  MMLanScan
//
//  Created by Michalis Mavris on 11/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "MainVC.h"
#import "Device.h"
#import "DeviceCell.h"
#import "LANProperties.h"
#import "MMLANScanner.h"

@interface MainVC () <UITableViewDataSource,UITableViewDelegate,MMLANScannerDelegate>
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBarTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableVTopContraint;

@property NSMutableArray *connectedDevices;
@property(nonatomic,strong)MMLANScanner *lanScanner;
@end

@implementation MainVC {
    BOOL isScanning;
}

- (void)viewDidLoad {
   
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [self.navigationBarTitle setTitle:[NSString stringWithFormat:@"SSID: %@",[LANProperties fetchSSIDInfo]]];
}

- (IBAction)refresh:(id)sender {
    
    [self startScanning];
}

-(void)startScanning {

    [self showProgressBar];
    
    [self.navigationBarTitle setTitle:[NSString stringWithFormat:@"SSID: %@",[LANProperties fetchSSIDInfo]]];
    
    [self.lanScanner stop];
    self.lanScanner = [[MMLANScanner alloc] initWithDelegate:self];
    self.connectedDevices = [[NSMutableArray alloc] init];
    
    [self.tableV reloadData];
    
    [self.lanScanner start];
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

#pragma mark LAN Scanner delegate method
-(void)lanScanDidFindNewDevice:(Device*)device{
        
    //Check if the Device is already added
    if (![self.connectedDevices containsObject:device]) {
       
        [self.connectedDevices addObject:device];
    }
    
    [self.tableV reloadData];
}

-(void)lanScanDidFinishScanning{
    
    [self hideProgressBar];
   
    [[[UIAlertView alloc] initWithTitle:@"Scan Finished" message:[NSString stringWithFormat:@"Number of devices connected to the Local Area Network : %lu", (unsigned long)self.connectedDevices.count] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

-(void)lanScanProgressPinged:(NSInteger)pingedHosts from:(NSInteger)overallHosts {
    
    [self.progressView setProgress:(float)pingedHosts/overallHosts];
}

-(void)lanScanDidFailedToScan {

    [self hideProgressBar];

    [[[UIAlertView alloc] initWithTitle:@"Failed to scan" message:[NSString stringWithFormat:@"Please make sure that you are connected to a WiFi before starting LAN Scan"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - UITableView Delegates
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    return [self.connectedDevices count];
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *tableIdentifier = @"DeviceCell";
    
    DeviceCell *cell = (DeviceCell*)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    if (cell == nil) {
        cell = [[DeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    Device *nd = [self.connectedDevices objectAtIndex:indexPath.row];
    
    cell.ipLabel.text = nd.ipAddress;
    cell.macAddressLabel.text = nd.macAddress;
    
    return cell;
}


@end
