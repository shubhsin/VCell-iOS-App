//
//  SimJobButtonCell.h
//  VCell
//
//  Created by Aciid on 20/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//
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
