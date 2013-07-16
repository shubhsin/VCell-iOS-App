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
    userDefaults  = [NSUserDefaults standardUserDefaults];
    
    if([userDefaults objectForKey:BM_DISPLAYSEGMENTINDEX])
        displaySegmentIndex = [[userDefaults objectForKey:BM_DISPLAYSEGMENTINDEX] integerValue];
    else
        displaySegmentIndex = APPLICATIONS_SEGMENT;

    self.appSimSegmentControl.selectedSegmentIndex = displaySegmentIndex;
    
    numberOfObjectsReceived = [[userDefaults objectForKey:BM_NUMBEROFOBJECTS] integerValue];
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
    numberOfObjectsReceived = [jsonData count];
    
    [userDefaults setObject:[NSNumber numberWithInteger:numberOfObjectsReceived] forKey:BM_NUMBEROFOBJECTS];
    [userDefaults synchronize];
    
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
    
    switch (displaySegmentIndex) {
        case BIOMODELS_SEGMENT:
            return @"";
        case APPLICATIONS_SEGMENT:
            bioModel = [baseObject biomodel];
            break;
        case SIMULATIONS_SEGMENT:
            bioModel = [[baseObject application] biomodel];
            break;
    }
        
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
    
    // Edit the sort key as appropriate.
        
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
        
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

#pragma mark - NSFetchedResults delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    oldNumberOfSections = [self.tableView numberOfSections];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self updateNumRow];
    [self.tableView reloadData];
    if(rowNum > [[URLparams objectForKey:BM_MAXROWS] integerValue] && displaySegmentIndex != BIOMODELS_SEGMENT)
        [Functions scrollToFirstRowOfNewSectionsWithOldNumberOfSections:oldNumberOfSections tableView:self.tableView];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    self.fetchedResultsController = [self fetchedResultsController];
    [self.tableView reloadData];
}
@end
