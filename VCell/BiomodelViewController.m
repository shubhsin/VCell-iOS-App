//
//  BiomodelViewController.m
//  VCell
//
//  Created by Aciid on 11/07/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "BiomodelViewController.h"

@interface BiomodelViewController ()
{
    //HUD Variables
    MBProgressHUD *HUD;
    long long expectedLength;
	long long currentLength;
    
    //Class Vars
    NSUInteger numberOfObjectsReceived;
    NSMutableData *connectionData;
    NSUInteger rowNum; //current start row of the data to request
    NSMutableDictionary *URLparams;
}
@end

@implementation BiomodelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(initDictAndstartLoading:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
   
    // Test listing all Biomodels from the store
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:BIOMODEL_ENTITY inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:nil];
    for (Biomodel *biomodel in fetchedObjects)
        NSLog(@"Name: %@", biomodel.bmKey);

}


- (void)initDictAndstartLoading:(id)sender
{
    [Functions deleteAllObjects:BIOMODEL_ENTITY inManagedObjectContext:self.managedObjectContext];

    [self initURLParamDict];
    rowNum = 1;
    [self startLoading];
    if(sender != nil)
        [(UIRefreshControl *)sender endRefreshing];
    

}

#pragma mark - Fetch JSON

- (void)initURLParamDict
{
    NSArray *keys=  [NSArray arrayWithObjects:
                     BM_BEGIN_STAMP,
                     BM_END_STAMP,
                     BM_MAXROWS,
                     BIOMODELID,
                     nil];
    
    NSArray *objects = [NSArray arrayWithObjects:
                        @"",
                        @"",
                        @"10",
                        @"",
                        nil];
    
    URLparams = [Functions initURLParamDictWithFileName:BIOMODEL_FILTERS_FILE Keys:keys AndObjects:objects];
}
- (void)startLoading
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@startRow=%d",BIOMODEL_URL,[Functions contructUrlParamsOnDict:URLparams],rowNum]];
    NSLog(@"%@",url);
    Functions *functions = [(AppDelegate*)[[UIApplication sharedApplication] delegate] functions];
    [functions fetchJSONFromURL:url WithrowNum:rowNum AddHUDToView:self.navigationController.view delegate:self];
}

#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}

#pragma mark - fetch JSON delegate

- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Make an empty array
    NSMutableArray *biomodels = [NSMutableArray array];
    
    // Add the objects in the array
    for(NSDictionary *dict in jsonData)
    {        
        Biomodel *biomodel = [Biomodel biomodelWithDict:dict inContext:context];
        [biomodels addObject:biomodel];
    }
    numberOfObjectsReceived = [biomodels count];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Biomodel *bioModel = [[[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]] application] biomodel];
    return [bioModel name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:SIMULATION_ENTITY inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    //[fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"application.biomodel.savedDate" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"application.biomodel.bmKey" cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    
    return _fetchedResultsController;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Simulation *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = object.name;
}

#pragma mark - NSFetchedResults delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
}


@end
