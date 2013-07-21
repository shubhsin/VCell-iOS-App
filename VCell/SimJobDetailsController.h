//
//  SimJobDetailsViewController.h
//  VCell
//
//  Created by Aciid on 26/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimJob.h"

@interface SimJobDetailsController : UITableViewController <UIAlertViewDelegate,UISplitViewControllerDelegate>

@property (assign, nonatomic, getter=isFromBiomodelTab) BOOL fromBiomodelTab;

//section 0
@property (weak, nonatomic) IBOutlet UITableViewCell *viewData;
@property (weak, nonatomic) IBOutlet UITableViewCell *parent;

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
