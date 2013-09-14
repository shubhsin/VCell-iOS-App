/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

@class SimJobsFiltersController;

@protocol SimJobsFiltersControllerDelegate

- (void)SimJobsFiltersControllerDidFinish:(SimJobsFiltersController *)controller;

@end

#import <UIKit/UIKit.h>
#import "SimJobsFiltersDetail.h"
#import "SimJobController.h"
#import "LoginViewController.h"

@interface SimJobsFiltersController : UITableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *dateBeginCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *dateEndCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *maxRowsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *serverIDCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *computeHostCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *simulationIDCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *hasDataCell;

@property (weak, nonatomic) id <SimJobsFiltersControllerDelegate> delegate;

- (IBAction)doneBtn:(id)sender;
- (IBAction)clearBtn:(id)sender;


@end
