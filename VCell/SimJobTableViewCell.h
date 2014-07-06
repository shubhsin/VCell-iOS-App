//
//  SimJobTableViewCell.h
//  VCell_14
//
//  Created by Ankit Agarwal on 11/06/14.
//  Copyright (c) 2014 ankit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimJobTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *simNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *simUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *simStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *simStartBtn;
@property (weak, nonatomic) IBOutlet UIButton *simDataBtn;

@end
