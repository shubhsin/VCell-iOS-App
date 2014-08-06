//
//  AddParamView.m
//  VCell
//
//  Created by Ankit Aggarwal on 06/08/14.
//  Copyright (c) 2014 vcell. All rights reserved.
//

#import "AddParamView.h"
#import "ParameterSelectTableViewController.h"

@implementation AddParamView

- (IBAction)segmentControlChanged:(id)sender
{
    
}

- (IBAction)addBtnClicked:(id)sender
{
    [self.superview removeFromSuperview];
    self.parameterSelectTableViewController.tableView.scrollEnabled = YES;
    self.parameterSelectTableViewController.tableView.allowsSelection = YES;
}

@end
