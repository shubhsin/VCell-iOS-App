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
    self.cardiTextFIeld.enabled = NO;
    self.cardiTextFIeld.text = self.override.cardinality ? self.override.cardinality.stringValue : @"0";
}
- (IBAction)stepperValueChanged:(id)sender {
    self.cardiTextFIeld.text = [NSString stringWithFormat:@"%.0f", self.stepper.value];
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
            self.stepper.hidden = YES;
            self.valueLabel.text = [NSString stringWithFormat:@"Default Value: %@",self.override.values[0]];
            [self.valueLabel sizeToFit];
            break;
        case segmentDependant:
        case segmentSingle:
            self.valueLabel.hidden = NO;
            self.valueTextField.hidden = NO;
            self.cardiLabel.hidden = YES;
            self.cardiTextFIeld.hidden = YES;
            self.stepper.hidden = YES;
            self.valueLabel.text = @"Expression";
            [self.valueLabel sizeToFit];
            break;
        case segmentList:
            self.valueLabel.hidden = NO;
            self.valueTextField.hidden = NO;
            self.cardiLabel.hidden = YES;
            self.cardiTextFIeld.hidden = YES;
            self.stepper.hidden = YES;
            self.valueLabel.text = @"Values";
            [self.valueLabel sizeToFit];
            break;
        case segmentLinear:
        case segmentLog:
            self.valueLabel.hidden = NO;
            self.valueTextField.hidden = NO;
            self.cardiLabel.hidden = NO;
            self.cardiTextFIeld.hidden = NO;
            self.stepper.hidden = NO;
            self.valueLabel.text = @"Values";
            [self.valueLabel sizeToFit];
            break;
        default:
            break;
    }
}

- (IBAction)addBtnClicked:(id)sender
{
    
    /*
     typedef enum : NSUInteger {
     LogInterval,
     List,
     Single,
     LinearInterval,
     Dependent
     } OverrideType;
     */
    
    NSMutableArray *overrides = self.parameterSelectTableViewController.application.overrides;
    NSScanner *scanner = [NSScanner scannerWithString:self.valueTextField.text];
    switch (self.segmentControl.selectedSegmentIndex) {
        case segmentNone:
            self.override.cardinality = @(1);
            [overrides addObject:self.override];
            break;
        case segmentDependant:
            self.override.type = Dependent;
            self.override.cardinality = @(1);
            if(!([scanner scanDouble:nil] && [scanner isAtEnd])) {
                [self showErrorAlert];
                return;
            }
            self.override.values = @[@(self.valueTextField.text.doubleValue)];
            [overrides addObject:self.override];
            break;
        case segmentSingle:
            self.override.type = Single;
            self.override.cardinality = @(1);
            if(!([scanner scanDouble:nil] && [scanner isAtEnd])) {
                [self showErrorAlert];
                return;
            }
            self.override.values = @[@(self.valueTextField.text.doubleValue)];
            [overrides addObject:self.override];
            break;
        case segmentList:
            self.override.type = List;
            self.override.cardinality = @(1);
            self.override.values = [self overrideValuesCommaSeperated]; //@[@(self.valueTextField.text.doubleValue)];
            if(!self.override.values)
                return;
            [overrides addObject:self.override];
            break;
        case segmentLinear:
            self.override.type = LinearInterval;
            self.override.cardinality = [NSNumber numberWithInt:self.cardiTextFIeld.text.intValue];
            self.override.values = [self overrideValuesCommaSeperated];
            if(!self.override.values)
                return;
            [overrides addObject:self.override];
            break;
        case segmentLog:
            self.override.type = LogInterval;
            self.override.cardinality = [NSNumber numberWithInt:self.cardiTextFIeld.text.intValue];
            self.override.values = [self overrideValuesCommaSeperated];
            if(!self.override.values)
                return;
            [overrides addObject:self.override];
            break;
        default:
            break;
    }
    [self.superview removeFromSuperview];
    [self.parameterSelectTableViewController.tableView reloadData];
    self.parameterSelectTableViewController.tableView.scrollEnabled = YES;
    self.parameterSelectTableViewController.tableView.allowsSelection = YES;
}

- (NSArray*)overrideValuesCommaSeperated
{
    NSArray *seperatedValues = [self.valueTextField.text componentsSeparatedByString:@","];
    __block NSMutableArray *values = [NSMutableArray array];

    [seperatedValues enumerateObjectsUsingBlock:^(NSString *val, NSUInteger idx, BOOL *stop) {
        NSScanner *scanner = [NSScanner scannerWithString:val];
        if(!([scanner scanDouble:nil] && [scanner isAtEnd])) {
            [self showErrorAlert];
            values = nil;
            return;
        }
        [values addObject:@(val.doubleValue)];
    }];
    
    return values;
}

- (void)showErrorAlert
{
    NSString *msg;
    switch (self.segmentControl.selectedSegmentIndex) {

        case segmentDependant:
        case segmentSingle:
            msg = @"Please enter a double Value";
            break;
        case segmentList:
        case segmentLinear:
        case segmentLog:
            msg = @"Please enter comma seperated double Values";
            break;
        default:
            break;
    }
    [[[UIAlertView alloc] initWithTitle:@"error" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (IBAction)cancelBtnClicked:(id)sender
{
    [self.superview removeFromSuperview];
    self.parameterSelectTableViewController.tableView.scrollEnabled = YES;
    self.parameterSelectTableViewController.tableView.allowsSelection = YES;
}

@end
