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
#import "SimJobsFiltersController.h"
#import "SimJob.h"
#import "SimJobCell.h"
#import "AppDelegate.h"
#import "SimJobButtonCell.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "SimJobDetailsController.h"
//Constants for sorts
#define BIOMODEL_SORT @"BioModel"
#define DATE_SORT @"Date"


//Tags for buttons
#define COMPLETED_BTN 10 // completed
#define RUNNING_BTN 20   // running, dispatched, waiting, queued
#define STOPPED_BTN 30  // stopped, failed

//Search Scope button index constants
#define SIMULATION_SCOPE 0
#define SIMKEY_SCOPE 1
#define APPLICATION_SCOPE 2
#define BIOMODEL_SCOPE 3

//constants for URL params
#define BEGIN_STAMP @"submitLow"
#define END_STAMP @"submitHigh"
#define MAXROWS @"maxRows"
#define SERVERID @"serverId"
#define COMPUTEHOST @"computeHost+value%3D"
#define SIMID @"simId"
#define JOBID @"jobId"
#define TASKID @"taskId"
#define HASDATA @"hasData"

@interface SimJobController : UITableViewController <MBProgressHUDDelegate, UISearchBarDelegate, UISearchDisplayDelegate, SimJobsFiltersControllerDelegate,SimJobButtonCellDelegate,FetchJSONDelegate>


@property (strong, nonatomic) SimJobDetailsController *simJobDetailsController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *biomodelDateSwapBtn;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
- (IBAction)bioModelDateSwap:(id)sender;
- (void)updatDataOnBtnPressedWithButtonTag:(int)tag AndButtonActive:(BOOL)active;
@end
