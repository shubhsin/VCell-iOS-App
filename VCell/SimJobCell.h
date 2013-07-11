//
//  SimJobCell.h
//  VCell
//
//  Created by Aciid on 11/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimJobCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *simName;
@property (nonatomic, weak) IBOutlet UILabel *status;
@property (nonatomic, weak) IBOutlet UILabel *jobIndex;
@property (nonatomic, weak) IBOutlet UILabel *appName;
@property (nonatomic, weak) IBOutlet UILabel *startDate;
@property (nonatomic, weak) IBOutlet UIButton *dataBtn;
@property (nonatomic, weak) IBOutlet UIButton *bioModelBtn;

@end
