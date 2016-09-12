//
//  DeviceCell.h
//  MMLanScan
//
//  Created by Michalis Mavris on 12/08/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ipLabel;
@property (weak, nonatomic) IBOutlet UILabel *macAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostnameLabel;

@end
