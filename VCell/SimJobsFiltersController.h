//
//  SimJobsFiltersController.h
//  VCell
//
//  Created by Aciid on 25/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimJobsFiltersDetail.h"
#import "SimJobController.h"

@interface SimJobsFiltersController : UITableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *dateBeginCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *dateEndCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *maxRowsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *serverIDCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *computeHostCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *simulationIDCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *jobIDCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *taskIDCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *hasDataCell;

@end
