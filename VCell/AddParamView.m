//
//  AddParamView.m
//  VCell
//
//  Created by Ankit Aggarwal on 06/08/14.
//  Copyright (c) 2014 vcell. All rights reserved.
//

#import "AddParamView.h"
#import "ParameterSelectTableViewController.h"


enum segments {
    segmentNone = 0,
    segmentSingle,
    segmentList,
    segmentLinear,
    segmentLog,
    segmentDependant
};

@implementation AddParamView

- (void)awakeFromNib
{
    
}

-(void)setOverride:(ApplicationOverride *)override
{
    _override = override;
    [self segmentControlChanged:nil];
}

- (IBAction)segmentControlChanged:(id)sender
{
    switch (self.segmentControl.selectedSegmentIndex) {
        case segmentNone:
            self.valueLabel.hidden = NO;
            self.valueTextField.hidden = YES;
            self.cardiLabel.hidden = YES;
            self.cardiTextFIeld.hidden = YES;
            self.valueLabel.text = [NSString stringWithFormat:@"Default Value: %@",self.override.values[0]];
            [self.valueLabel sizeToFit];
            break;
        case segmentDependant:
        case segmentSingle:
            self.valueLabel.hidden = NO;
            self.valueTextField.hidden = NO;
            self.cardiLabel.hidden = YES;
            self.cardiTextFIeld.hidden = YES;
            self.valueLabel.text = @"Expression";
            [self.valueLabel sizeToFit];
            break;
        case segmentList:
            self.valueLabel.hidden = NO;
            self.valueTextField.hidden = NO;
            self.cardiLabel.hidden = YES;
            self.cardiTextFIeld.hidden = YES;
            self.valueLabel.text = @"Values";
            [self.valueLabel sizeToFit];
            break;
        case segmentLinear:
        case segmentLog:
            self.valueLabel.hidden = NO;
            self.valueTextField.hidden = NO;
            self.cardiLabel.hidden = NO;
            self.cardiTextFIeld.hidden = NO;
            self.valueLabel.text = @"Values";
            [self.valueLabel sizeToFit];
            break;
        default:
            break;
    }
}

- (IBAction)addBtnClicked:(id)sender
{
    [self.superview removeFromSuperview];
    self.parameterSelectTableViewController.tableView.scrollEnabled = YES;
    self.parameterSelectTableViewController.tableView.allowsSelection = YES;
}

@end
