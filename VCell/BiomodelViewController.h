//
//  BiomodelViewController.h
//  VCell
//
//  Created by Aciid on 11/07/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "Biomodel.h"
#import "Application.h"
#import "Simulation.h"

//constants for URL params
#define BM_BEGIN_STAMP @"savedLow"
#define BM_END_STAMP @"savedHigh"
#define BM_MAXROWS @"maxRows"
#define BIOMODELID @"bmId"

//coredata entity constants
#define BIOMODEL_ENTITY @"Biomodel"
#define APPLICATION_ENTITY @"Application"
#define SIMULATION_ENTITY @"Simulation"

@interface BiomodelViewController : UITableViewController <NSFetchedResultsControllerDelegate, FetchJSONDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
