/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

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
