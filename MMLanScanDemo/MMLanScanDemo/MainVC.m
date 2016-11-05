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

@implementation MainVC

#pragma mark - On Load Methods
- (void)viewDidLoad {
   
    [super viewDidLoad];
    
    //Initializing the presenter
    self.presenter = [[MainPresenter alloc]initWithDelegate:self];
    
    //Adding observers to presenter (in order to update the UI)
    [self.presenter addObserver:self forKeyPath:@"connectedDevices" options:NSKeyValueObservingOptionNew context:nil];
    [self.presenter addObserver:self forKeyPath:@"progressValue" options:NSKeyValueObservingOptionNew context:nil];
    [self.presenter addObserver:self forKeyPath:@"isScanRunning" options:NSKeyValueObservingOptionNew context:nil];

    //This is not a production code. Run this command only if you have a new OUI.txt file to parse. After parsing the default location of data.plist will be on DocumentsDirectory. Then you can add the new data.plist to your project and build it.
    //[OUIParser parseOUIWithSourceFilePath:nil andOutputFilePath:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [self.navigationBarTitle setTitle:[self.presenter ssidName]];
}

#pragma mark - Refresh button pressed
- (IBAction)refresh:(id)sender {
    
    [self scanButtonClicked];
}

-(void)scanButtonClicked {

    [self showProgressBar];
    
    [self.navigationBarTitle setTitle:[self.presenter ssidName]];
    
    [self.presenter scanButtonClicked];
        
}

#pragma mark - Show/Hide progress
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

-(void)mainPresenterIPSearchFailed {
    
    [[[UIAlertView alloc] initWithTitle:@"Failed to scan" message:[NSString stringWithFormat:@"Please make sure that you are connected to a WiFi before starting LAN Scan"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
};

-(void)mainPresenterIPSearchCancelled {
    
    [self hideProgressBar];
    [self.tableV reloadData];
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

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self.presenter){
       
        if ([keyPath isEqualToString:@"connectedDevices"]) {
            
            [self.tableV reloadData];
        }
        else if ([keyPath isEqualToString:@"progressValue"]) {
            
            [self.progressView setProgress:self.presenter.progressValue];
        }
        else if ([keyPath isEqualToString:@"isScanRunning"]) {
            
            BOOL isScanRunning= [[change valueForKey:NSKeyValueChangeNewKey] boolValue];
    
            [self.scanButton setImage:isScanRunning ? [UIImage imageNamed:@"stopBarButton"] :[UIImage imageNamed:@"refreshBarButton"]];
            
        }
    }
}

@end
