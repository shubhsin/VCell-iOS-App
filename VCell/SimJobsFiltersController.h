//
//  SimJobsFiltersController.h
//  VCell
//
//  Created by Aciid on 25/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//
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
