//
//  BiomodelDetailsViewController.h
//  VCell
//
//  Created by Aciid on 17/07/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Biomodel.h"
#import "Application.h"
#import "Simulation.h"
#import "SimJob.h"
#import "SimJobDetailsController.h"

@interface BiomodelDetailsViewController : UITableViewController <FetchJSONDelegate>

- (void)setObject:(id)object;

@end
