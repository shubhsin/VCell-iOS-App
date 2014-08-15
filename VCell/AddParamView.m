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
    if(!override) {
        self.segmentControl.selectedSegmentIndex = segmentNone;
        [self segmentControlChanged:nil];
        return;
    }
    switch (override.type) {
        case LogInterval:
            self.segmentControl.selectedSegmentIndex = segmentLog;
            break;
        case List:
            self.segmentControl.selectedSegmentIndex = segmentList;
            break;
        case Single:
            self.segmentControl.selectedSegmentIndex = segmentSingle;
            break;
        case LinearInterval:
            self.segmentControl.selectedSegmentIndex = segmentLinear;
            break;
        case Dependent:
            self.segmentControl.selectedSegmentIndex = segmentDependant;
            break;
        default:
            break;
    }
    self.cardiTextFIeld.text = override.cardinality.stringValue;
    NSMutableString *value = [NSMutableString string];
    [override.values enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        [value appendString:obj.stringValue];
        if(idx == override.values.count - 1)
            return;
        [value appendString:@", "];
    }];
    self.valueTextField.text = value;
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
            self.valueLabel.text = [NSString stringWithFormat:@"Default Value: %@",self.param.defaultValue];
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
            break;
        case segmentDependant:
            _override = [[ApplicationOverride alloc] init];
            self.override.name = self.param.name;
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
            _override = [[ApplicationOverride alloc] init];
            self.override.name = self.param.name;
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
            _override = [[ApplicationOverride alloc] init];
            self.override.name = self.param.name;
            self.override.type = List;
            self.override.cardinality = @(1);
            self.override.values = [self overrideValuesCommaSeperated]; //@[@(self.valueTextField.text.doubleValue)];
            if(!self.override.values)
                return;
            [overrides addObject:self.override];
            break;
        case segmentLinear:
            _override = [[ApplicationOverride alloc] init];
            self.override.name = self.param.name;
            self.override.type = LinearInterval;
            self.override.cardinality = [NSNumber numberWithInt:self.cardiTextFIeld.text.intValue];
            self.override.values = [self overrideValuesCommaSeperated];
            if(!self.override.values)
                return;
            [overrides addObject:self.override];
            break;
        case segmentLog:
            _override = [[ApplicationOverride alloc] init];
            self.override.name = self.param.name;
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
