//
//  BiomodelViewController.h
//  VCell
//
//  Created by Aciid on 11/07/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "Biomodel.h"
#import "Application.h"
#import "Simulation.h"

#define BM_DISPLAYSEGMENTINDEX @"displaySegmentIndex"
#define BM_NUMBEROFOBJECTS @"numberOfObjects" //to keep track of number of objects received in last request

#define BIOMODELS_SEGMENT 0
#define APPLICATIONS_SEGMENT 1
#define SIMULATIONS_SEGMENT 2

//constants for URL params
#define BM_BEGIN_STAMP @"savedLow"
#define BM_END_STAMP @"savedHigh"
#define BM_MAXROWS @"maxRows"
#define BIOMODELID @"bmId"

//coredata entity constants
#define BIOMODEL_ENTITY @"Biomodel"
#define APPLICATION_ENTITY @"Application"
#define SIMULATION_ENTITY @"Simulation"

@interface BiomodelViewController : UITableViewController <NSFetchedResultsControllerDelegate, FetchJSONDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *searchFetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UISegmentedControl *appSimSegmentControl;
- (IBAction)appSimSwap:(id)sender;

@end
