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
    BOOL displayApplications;
    Functions *functions;
    NSUInteger oldNumberOfSections;
    NSMutableData *connectionData;
    NSUInteger rowNum; //current start row of the data to request
    NSMutableDictionary *URLparams;
    NSUserDefaults *userDefaults;
}
@end

@implementation BiomodelViewController

- (void)loadPrefs
{
    userDefaults  = [NSUserDefaults standardUserDefaults];
    
    if([userDefaults objectForKey:@"displayApplications"])
        displayApplications = [[userDefaults objectForKey:@"displayApplications"] boolValue];
    else
        displayApplications = true;

    if(displayApplications)
        self.appSimSegmentControl.selectedSegmentIndex = APPLICATIONS_SEGMENT;
    else
        self.appSimSegmentControl.selectedSegmentIndex = SIMULATIONS_SEGMENT;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadPrefs];
    [self updateNumRow];
    functions = [[Functions alloc] init];
    //Pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(initDictAndstartLoading:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
}


- (void)initDictAndstartLoading:(id)sender
{

    [Functions deleteAllObjects:BIOMODEL_ENTITY inManagedObjectContext:self.managedObjectContext];
     // To get rid of rougue simulations, applications if any
    [Functions deleteAllObjects:SIMULATION_ENTITY inManagedObjectContext:self.managedObjectContext];
    [Functions deleteAllObjects:APPLICATION_ENTITY inManagedObjectContext:self.managedObjectContext];
    
    rowNum = 0;
    [self initURLParamDict];
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

- (void)updateNumRow
{
    // Test listing all Biomodels from the store
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:BIOMODEL_ENTITY inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesSubentities:NO];
    rowNum = [context countForFetchRequest:fetchRequest error:nil];
}

- (void)startLoading
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@startRow=%d",
                                       BIOMODEL_URL,[Functions contructUrlParamsOnDict:URLparams],rowNum+1]];
    NSLog(@"%@",url);
    [functions fetchJSONFromURL:url WithrowNum:rowNum+1 AddHUDToView:self.navigationController.view delegate:self];
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

    // Add the objects in the array
    for(NSDictionary *dict in jsonData)
        [Biomodel biomodelWithDict:dict inContext:context];
    
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
    Biomodel *bioModel;
    
    id baseObject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    
    bioModel = displayApplications ? [baseObject biomodel] : [[baseObject application] biomodel];
    
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
    
    NSString *entityName =  displayApplications ? APPLICATION_ENTITY : SIMULATION_ENTITY;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSString *sortKey = displayApplications ? @"biomodel.savedDate" : @"application.biomodel.savedDate";
        
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    NSString *sectionKeyPath = displayApplications ? @"biomodel.bmKey" : @"application.biomodel.bmKey";
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionKeyPath cacheName:nil];
    
    
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
    id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [object name];
}

#pragma mark - NSFetchedResults delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    oldNumberOfSections = [self.tableView numberOfSections];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self updateNumRow];
    [self.tableView reloadData];
    if(rowNum > [[URLparams objectForKey:BM_MAXROWS] integerValue])
    {
        NSIndexPath *firstCellOfNewData = [NSIndexPath indexPathForRow:0 inSection:oldNumberOfSections];
    
        //Scroll to newly added section and highlight animate the first row
    
        [UIView animateWithDuration:0.2 animations:^{
            //Scroll to row 0 of the new added section
            [self.tableView scrollToRowAtIndexPath:firstCellOfNewData atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        } completion:^(BOOL finished){
            //Highlight after scrollToRowAtIndexPath finished
            UITableViewCell *cellToHighlight = [self.tableView cellForRowAtIndexPath:firstCellOfNewData];
        
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseInOut animations:^
             {
                 //Highlight the cell
                 [cellToHighlight setHighlighted:YES animated:YES];
             } completion:^(BOOL finished)
             {
                 [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseInOut animations:^
                  {
                      //Unhighlight the cell
                      [cellToHighlight setHighlighted:NO animated:YES];
                  } completion: NULL];
             }];
        }];
    }
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger sections = [[self.fetchedResultsController sections] count];
    if(sections > 0)
    if(indexPath.section == sections -1 &&
       indexPath.row == [self.tableView numberOfRowsInSection:sections - 1] - 1 &&
       tableView == self.tableView)
    {
        [self startLoading];
    }
}

- (IBAction)appSimSwap:(id)sender
{    
    if(self.appSimSegmentControl.selectedSegmentIndex == APPLICATIONS_SEGMENT)
        displayApplications = YES;
    
    if(self.appSimSegmentControl.selectedSegmentIndex == SIMULATIONS_SEGMENT)
        displayApplications = NO;

    [userDefaults setObject:[NSNumber numberWithBool:displayApplications] forKey:@"displayApplications"];
    [userDefaults synchronize];

    self.fetchedResultsController = nil;
    self.fetchedResultsController = [self fetchedResultsController];
    [self.tableView reloadData];
}
@end
