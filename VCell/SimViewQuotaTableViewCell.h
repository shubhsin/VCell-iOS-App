//
//  SimViewQuotaTableViewCell.h
//  VCell_14
//
//  Created by Aciid on 05/06/14.
//  Copyright (c) 2014 ankit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimViewQuotaTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *quotaRunningLabel;
@property (weak, nonatomic) IBOutlet UILabel *quotaMaxLabel;
@property (weak, nonatomic) IBOutlet UILabel *quotaWaitingLabel;

@end
