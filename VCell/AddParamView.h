//
//  AddParamView.h
//  VCell
//
//  Created by Ankit Aggarwal on 06/08/14.
//  Copyright (c) 2014 vcell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NewApplication.h"

@class ParameterSelectTableViewController;

@interface AddParamView : UIView

@property (weak, nonatomic) ApplicationOverride *override;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (weak, nonatomic) IBOutlet UILabel *cardiLabel;
@property (weak, nonatomic) IBOutlet UITextField *cardiTextFIeld;

@property (weak, nonatomic) ParameterSelectTableViewController *parameterSelectTableViewController;

- (IBAction)segmentControlChanged:(id)sender;
- (IBAction)addBtnClicked:(id)sender;

@end
