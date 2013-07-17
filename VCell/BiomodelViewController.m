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
    NSString *actionSheetPref;
    NSUInteger numberOfObjectsReceived;
    NSUInteger displaySegmentIndex;
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
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    if([userDefaults objectForKey:BM_DISPLAYSEGMENTINDEX])
        displaySegmentIndex = [[userDefaults objectForKey:BM_DISPLAYSEGMENTINDEX] integerValue];
    else
        displaySegmentIndex = APPLICATIONS_SEGMENT;

    self.appSimSegmentControl.selectedSegmentIndex = displaySegmentIndex;
    
    numberOfObjectsReceived = [[userDefaults objectForKey:BM_NUMBEROFOBJECTS] integerValue];
    
    actionSheetPref = [userDefaults objectForKey:BM_ACTIONSHEETPREF];
}

- (void)initActionSheet
{
    NSArray *keys = [NSArray arrayWithObjects:
                     @"myModels",
                     @"public",
                     @"shared",
                     @"educational",
                     @"tutorial",
                     nil];
   
    NSArray *objects = [NSArray arrayWithObjects:
                        [NSMutableString stringWithString:@"My Models"],
                        [NSMutableString stringWithString:@"Public"],
                        [NSMutableString stringWithString:@"Shared"],
                        [NSMutableString stringWithString:@"Educational"],
                        [NSMutableString stringWithString:@"Tutorial"], nil];
    
    NSDictionary *buttonTitlesDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    if(actionSheetPref == nil)
    {
        actionSheetPref = [objects objectAtIndex:0];
        [userDefaults setObject:actionSheetPref forKey:BM_ACTIONSHEETPREF];
        [userDefaults synchronize];
    }
    
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        if([obj isEqualToString:actionSheetPref])
        {
            [obj appendString:TICK_MARK];
            *stop = YES;
        }
    }];
    
    self.actionSheet = nil; //reclaim memory from last action sheet
    self.actionSheet = [[UIActionSheet alloc]
                        initWithTitle:@"Select Biomodel Group"
                        delegate:self
                        cancelButtonTitle:@"Cancel"
                        destructiveButtonTitle:[buttonTitlesDict objectForKey:@"myModels"]
                        otherButtonTitles:
                        [buttonTitlesDict objectForKey:@"shared"],
                        [buttonTitlesDict objectForKey:@"public"],
                        [buttonTitlesDict objectForKey:@"educational"],
                        [buttonTitlesDict objectForKey:@"tutorial"],nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadPrefs];
    [self initActionSheet];
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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@startRow=%d&owner=%@",
                                       BIOMODEL_URL,[Functions contructUrlParamsOnDict:URLparams],rowNum+1,actionSheetPref]];
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
    numberOfObjectsReceived = [jsonData count];
    
    [userDefaults setObject:[NSNumber numberWithInteger:numberOfObjectsReceived] forKey:BM_NUMBEROFOBJECTS];
    [userDefaults synchronize];
    
    NSManagedObjectContext *context = [self managedObjectContext];

    // Add the objects in the array
    for(NSDictionary *dict in jsonData)
        [Biomodel biomodelWithDict:dict inContext:context biomodelGroup:actionSheetPref];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[[self fetchedResultsControllerForTableView:tableView] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsControllerForTableView:tableView] sections][section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(displaySegmentIndex == BIOMODELS_SEGMENT) return nil;
    
    Biomodel *bioModel;
    id baseObject = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:
                     [NSIndexPath indexPathForRow:0 inSection:section]];
    
    switch (displaySegmentIndex) {
        case APPLICATIONS_SEGMENT:
            bioModel = [baseObject biomodel];
            break;
        case SIMULATIONS_SEGMENT:
            bioModel = [[baseObject application] biomodel];
            break;
    }
        
    return [bioModel name];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath  tableView:tableView];
    return cell;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    NSString *entityName, *sortKey, *sectionKeyPath;
    
    switch (displaySegmentIndex) {
            
        case BIOMODELS_SEGMENT:
            
            entityName = BIOMODEL_ENTITY;
            sortKey = @"savedDate";
            sectionKeyPath = nil;
            
            break;
        case APPLICATIONS_SEGMENT:
            
            entityName = APPLICATION_ENTITY;
            sortKey = @"biomodel.savedDate";
            sectionKeyPath = @"biomodel.bmKey";
            
            break;
        case SIMULATIONS_SEGMENT:
            
            entityName = SIMULATION_ENTITY;
            sortKey = @"application.biomodel.savedDate";
            sectionKeyPath =  @"application.biomodel.bmKey";
            
            break;
    }
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    //Set the predicate
    NSPredicate *searchPredicate;
    
    if(searchString)
        searchPredicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchString];
    
    NSPredicate *actionSheetPredicate = [NSPredicate predicateWithFormat:@"SELF.bmgroup like '%@'",actionSheetPref];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:
                              [NSArray arrayWithObjects:searchPredicate,actionSheetPredicate, nil]];
    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionKeyPath cacheName:nil];
    
    
    aFetchedResultsController.delegate = self;

	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    return aFetchedResultsController;

}

- (NSFetchedResultsController *)searchFetchedResultsController
{
    if (_searchFetchedResultsController != nil) {
        return _searchFetchedResultsController;
    }
    _searchFetchedResultsController = [self newFetchedResultsControllerWithSearch:self.searchDisplayController.searchBar.text];
    return _searchFetchedResultsController;

}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    _fetchedResultsController = [self newFetchedResultsControllerWithSearch:nil];
    return _fetchedResultsController;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    id object = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    cell.textLabel.text = [object name];

    if(displaySegmentIndex == BIOMODELS_SEGMENT)
    {
        UILabel *labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(160, 27, 140, 20)];

        cell.detailTextLabel.text = [object savedDateString];

        labelTwo.font = cell.detailTextLabel.font;
        labelTwo.textAlignment = NSTextAlignmentRight;
        labelTwo.textColor = [UIColor darkGrayColor];
        
        __block NSUInteger numberOfSim = 0;
        
        [[object applications] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            numberOfSim += [[obj simulations] count];
        }];
        
        labelTwo.text =  [NSString stringWithFormat:@"| A: %d | S: %d |",[[object applications] count], numberOfSim];
        
        [cell.contentView addSubview:labelTwo];
       
    }
    else if(displaySegmentIndex == APPLICATIONS_SEGMENT)
    {
        if ([cell.contentView subviews])
            for (UIView *subview in [cell.contentView subviews]) 
                [subview removeFromSuperview];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Simulations: %d",[[object simulations] count]];
    }
    else if(displaySegmentIndex == SIMULATIONS_SEGMENT)
    {
        if ([cell.contentView subviews])
            for (UIView *subview in [cell.contentView subviews])
                [subview removeFromSuperview];
        
        cell.detailTextLabel.text = [[object application] name];
    }

}


- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

#pragma mark - NSFetchedResults delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if(controller == self.fetchedResultsController)
        oldNumberOfSections = [self.tableView numberOfSections];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if(controller == self.fetchedResultsController)
    {
        [self.tableView reloadData];
        [self updateNumRow];
        if(rowNum > [[URLparams objectForKey:BM_MAXROWS] integerValue])
        {
            NSIndexPath *indexPath;
            if(displaySegmentIndex == BIOMODELS_SEGMENT)
                indexPath = [NSIndexPath indexPathForRow:rowNum - numberOfObjectsReceived inSection:0];
            else
                indexPath = [NSIndexPath indexPathForRow:0 inSection:oldNumberOfSections];
        
            [Functions scrollToFirstRowOfNewSectionsWithOldNumberOfSections:indexPath tableView:self.tableView];
        }
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BiomodelDetailsViewController *biomodelDetailsViewController = [[BiomodelDetailsViewController alloc] initWithStyle:UITableViewStylePlain];
    [biomodelDetailsViewController setObject:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath]];
    [self.navigationController pushViewController:biomodelDetailsViewController animated:YES];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView != self.tableView)
        return;
    
    NSUInteger sections = [[self.fetchedResultsController sections] count];
    if(sections > 0)
    if(numberOfObjectsReceived == [[URLparams objectForKey:BM_MAXROWS] integerValue] &&
       indexPath.section == sections -1 &&
       indexPath.row == [self.tableView numberOfRowsInSection:sections - 1] - 1 &&
       tableView == self.tableView)
    {
        [self startLoading];
    }
}

- (IBAction)appSimSwap:(id)sender
{
    [self.tableView setContentOffset:CGPointZero animated:NO]; // Scroll to top
    displaySegmentIndex = self.appSimSegmentControl.selectedSegmentIndex;
    
    [userDefaults setObject:[NSNumber numberWithInteger:displaySegmentIndex] forKey:BM_DISPLAYSEGMENTINDEX];
    [userDefaults synchronize];

    self.fetchedResultsController = nil;
    [self.tableView reloadData];
}

- (IBAction)selectOwnerBtnClicked:(id)sender
{

    [self.actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *btnIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
    if(![btnIndex isEqualToString:@"Cancel"])
    {
        actionSheetPref = btnIndex;
        [userDefaults setObject:actionSheetPref forKey:BM_ACTIONSHEETPREF];
        [userDefaults synchronize];
        [self initActionSheet];
        self.fetchedResultsController = nil;
        [self.tableView reloadData];
    }
}

#pragma mark - Search Delegates
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _searchFetchedResultsController = nil;
}

//Reload the main tableView when done with search
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    self.searchFetchedResultsController = nil;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    self.searchFetchedResultsController = nil;
}

@end
