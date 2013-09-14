/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

@class SimJobButtonCell;

@protocol SimJobButtonCellDelegate

- (void)updatDataOnBtnPressedWithButtonTag:(int)tag AndButtonActive:(BOOL)active;

@end

#import <UIKit/UIKit.h>
#import "SimJobController.h"

@interface SimJobButtonCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *completedBtn;
@property (weak, nonatomic) IBOutlet UIButton *runningBtn;
@property (weak, nonatomic) IBOutlet UIButton *stoppedBtn;
@property (weak, nonatomic) id <SimJobButtonCellDelegate> delegate;

- (IBAction)btnPressed:(id)sender;


@end
