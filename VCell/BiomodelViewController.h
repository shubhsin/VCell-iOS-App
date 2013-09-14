/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BiomodelCell.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "Biomodel.h"
#import "Application.h"
#import "Simulation.h"
#import "BiomodelDetailsViewController.h"
#import "AccessToken.h"
#import "LoginViewController.h"

#define BM_DISPLAYSEGMENTINDEX @"displaySegmentIndex"
#define BM_NUMBEROFOBJECTS @"numberOfObjects" //to keep track of number of objects received in last request
#define BM_ACTIONSHEETPREF @"bmActionSheetPref"
#define BM_SORTPREF @"bmsortPref"

#define BIOMODELS_SEGMENT 0
#define APPLICATIONS_SEGMENT 1
#define SIMULATIONS_SEGMENT 2

//constants for URL params
#define BM_BEGIN_STAMP @"savedLow"
#define BM_END_STAMP @"savedHigh"
#define BM_MAXROWS @"maxRows"
#define BIOMODELID @"bmId"
#define BMOWNER @"owner"

//coredata entity constants
#define BIOMODEL_ENTITY @"Biomodel"
#define APPLICATION_ENTITY @"Application"
#define SIMULATION_ENTITY @"Simulation"

//constants for sort order
#define DATE_DESC @"date_desc"
#define DATE_ASC @"date_asc"
#define NAME_ASC @"name_asc"
#define NAME_DESC @"name_desc"

#define IS_ONLINE_SEARCHED_BIOMODEL tableView == self.searchDisplayController.searchResultsTableView && displaySegmentIndex == BIOMODELS_SEGMENT
#define IS_ONLINE_SEARCHED_BIOMODEL_SECTION IS_ONLINE_SEARCHED_BIOMODEL && section == tableView.numberOfSections - 1

@interface BiomodelViewController : UITableViewController <NSFetchedResultsControllerDelegate, FetchJSONDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) UIActionSheet *actionSheet; //For owner
@property (strong, nonatomic) UIActionSheet *optionsActionSheet;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *searchFetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UISegmentedControl *appSimSegmentControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ownerBtn;

- (IBAction)appSimSwap:(id)sender;
- (IBAction)selectOwnerBtnClicked:(id)sender;
- (IBAction)optionBtnClicked:(id)sender;

@end
