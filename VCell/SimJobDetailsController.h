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
#import "SimJob.h"
#import "GraphAxisSelectController.h"

#define STARTSIMULATION @"Start Simulation"
#define STOPSIMULATION @"Stop Simulation"

@interface SimJobDetailsController : UITableViewController <UIAlertViewDelegate,UISplitViewControllerDelegate,FetchJSONDelegate>

@property (assign, nonatomic, getter=isFromBiomodelTab) BOOL fromBiomodelTab;

//section 0
@property (weak, nonatomic) IBOutlet UITableViewCell *viewData;
@property (weak, nonatomic) IBOutlet UITableViewCell *parent;
@property (weak, nonatomic) IBOutlet UITableViewCell *startStopSim;

//section 1
@property (weak, nonatomic) IBOutlet UITableViewCell *simKey;
@property (weak, nonatomic) IBOutlet UITableViewCell *simName;
@property (weak, nonatomic) IBOutlet UITableViewCell *status;
@property (weak, nonatomic) IBOutlet UITableViewCell *startDate;
@property (weak, nonatomic) IBOutlet UITableViewCell *msg;

//section 2
@property (weak, nonatomic) IBOutlet UITableViewCell *simContextKey;
@property (weak, nonatomic) IBOutlet UITableViewCell *simContextBranch;
@property (weak, nonatomic) IBOutlet UITableViewCell *simContextName;

//section 3
@property (weak, nonatomic) IBOutlet UITableViewCell *bioModelKey;
@property (weak, nonatomic) IBOutlet UITableViewCell *bioModelBranch;
@property (weak, nonatomic) IBOutlet UITableViewCell *bioModelName;

//section 4
@property (weak, nonatomic) IBOutlet UITableViewCell *username;
@property (weak, nonatomic) IBOutlet UITableViewCell *userKey;
@property (weak, nonatomic) IBOutlet UITableViewCell *jobId;
@property (weak, nonatomic) IBOutlet UITableViewCell *taskId;
@property (weak, nonatomic) IBOutlet UITableViewCell *htcJobId;

//section 5
@property (weak, nonatomic) IBOutlet UITableViewCell *site;
@property (weak, nonatomic) IBOutlet UITableViewCell *computeHost;
@property (weak, nonatomic) IBOutlet UITableViewCell *schStatus;

- (void)setObject:(SimJob*)object;

@end
