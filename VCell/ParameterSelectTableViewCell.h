//
//  ParameterSelectTableViewCell.h
//  VCell
//
//  Created by Ankit Aggarwal on 06/08/14.
//  Copyright (c) 2014 vcell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParameterSelectTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *context;
@property (weak, nonatomic) IBOutlet UILabel *defaultValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;

@property (assign, nonatomic) BOOL addedState;

@end
