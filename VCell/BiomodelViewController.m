/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

#import "BiomodelViewController.h"

@interface BiomodelViewController ()
{
    //HUD Variables
    MBProgressHUD *HUD;
    long long expectedLength;
	long long currentLength;
    
    //Class Vars
    NSString *actionSheetPref;
    NSDictionary *actionSheetDict;
    NSString *sortPref;
    NSDictionary *sortPrefDict;
    NSMutableDictionary *numberOfObjectsReceived;
    NSUInteger displaySegmentIndex;
    Functions *functions;
    Functions *functionOnlineSearch;
    NSUInteger oldNumberOfSections;
    NSMutableData *connectionData;
    NSUInteger rowNum; //current start row of the data to request
    NSMutableDictionary *URLparams;
    NSUserDefaults *userDefaults;
    NSMutableArray *onlineSearchedBiomodels; //Online Searched Biomodels
}

@end

@implementation BiomodelViewController

- (NSManagedObjectContext*)managedObjectContext
{
   if(_managedObjectContext == nil)
   {
       AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
       _managedObjectContext = appDelegate.managedObjectContext;
   }
    return _managedObjectContext;
}

- (void)loadPrefs
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    if([userDefaults objectForKey:BM_DISPLAYSEGMENTINDEX])
        displaySegmentIndex = [[userDefaults objectForKey:BM_DISPLAYSEGMENTINDEX] integerValue];
    else
        displaySegmentIndex = APPLICATIONS_SEGMENT;
    
    self.appSimSegmentControl.selectedSegmentIndex = displaySegmentIndex;
    
    numberOfObjectsReceived = [[userDefaults objectForKey:BM_NUMBEROFOBJECTS] mutableCopy];
    actionSheetPref = [userDefaults objectForKey:BM_ACTIONSHEETPREF];
    sortPref = [userDefaults objectForKey:BM_SORTPREF];
    [self initURLParamDict];
}

- (void)initActionSheet
{
    NSArray *buttonTitles = [NSArray arrayWithObjects:@"My Models",@"Public",@"Shared",@"Educational",@"Tutorial", nil];
    
    
    NSMutableArray *buttonMutableTitles = [NSMutableArray array];
    
    [buttonTitles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [buttonMutableTitles addObject:[NSMutableString stringWithString:obj]];
    }];
    
    
    if(!numberOfObjectsReceived)
    {
        
        numberOfObjectsReceived = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                              [NSNumber numberWithInteger:0],
                                                                              [NSNumber numberWithInteger:0],
                                                                              [NSNumber numberWithInteger:0],
                                                                              [NSNumber numberWithInteger:0],
                                                                              [NSNumber numberWithInteger:0],
                                                                              nil] forKeys:buttonTitles];
        
        [userDefaults setObject:numberOfObjectsReceived forKey:BM_NUMBEROFOBJECTS];
        [userDefaults synchronize];
    }

    actionSheetDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                               @"mine",
                                                               @"public",
                                                               @"shared",
                                                               @"educational",
                                                               @"tutorials"
                                                               , nil] forKeys:buttonTitles];
        
    if(!actionSheetPref)
    {
        actionSheetPref = [buttonTitles objectAtIndex:[AccessToken sharedInstance]?0:1]; //Select Public as default owner if user selected public access
        
        [userDefaults setObject:actionSheetPref forKey:BM_ACTIONSHEETPREF];
        [userDefaults synchronize];
    }
    
    [buttonMutableTitles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
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
                        destructiveButtonTitle:[buttonMutableTitles objectAtIndex:0]
                        otherButtonTitles:
                        [buttonMutableTitles objectAtIndex:1],
                        [buttonMutableTitles objectAtIndex:2],
                        [buttonMutableTitles objectAtIndex:3],
                        [buttonMutableTitles objectAtIndex:4],
                        nil];
    
}

- (void)initOptionsActionSheet
{
    
    NSArray *buttonTitles = [NSArray arrayWithObjects:@"Date (newest)", @"Date (oldest)", @"Name (A-Z)", @"Name (Z-A)", nil];
    
    NSMutableArray *buttonMutableTitles = [NSMutableArray array];
    
    [buttonTitles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [buttonMutableTitles addObject:[NSMutableString stringWithString:obj]];
    }];
    
    if(!sortPref)
    {
        actionSheetPref = [buttonTitles objectAtIndex:0];
        [userDefaults setObject:actionSheetPref forKey:BM_SORTPREF];
        [userDefaults synchronize];
    }
    
    sortPrefDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                            DATE_DESC,
                                                            DATE_ASC,
                                                            NAME_ASC,
                                                            NAME_DESC
                                                           , nil] forKeys:buttonTitles];
    
    [buttonMutableTitles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if([obj isEqualToString:sortPref])
        {
            [obj appendString:TICK_MARK];
            *stop = YES;
        }
    }];
    
    self.optionsActionSheet = nil; //reclaim memory from last action sheet
    self.optionsActionSheet = [[UIActionSheet alloc]
                        initWithTitle:@"Select Sort Order"
                        delegate:self
                        cancelButtonTitle:@"Cancel"
                        destructiveButtonTitle:@"Logout"
                        otherButtonTitles:
                        [buttonMutableTitles objectAtIndex:0],
                        [buttonMutableTitles objectAtIndex:1],
                        [buttonMutableTitles objectAtIndex:2],
                        [buttonMutableTitles objectAtIndex:3],
                        nil];

}
- (void)viewWillAppear:(BOOL)animated
{
    [self initOptionsActionSheet];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadPrefs];
    [self initActionSheet];
    [self updateNumRow];
    [self setOwnerBtnTitle];
    functions = [[Functions alloc] init];
    //Pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(initDictAndstartLoading:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
}

- (void)initDictAndstartLoading:(id)sender
{
    [Functions deleteAllObjects:BIOMODEL_ENTITY inManagedObjectContext:self.managedObjectContext withOwner:actionSheetPref];
    rowNum = 0;
    [self initURLParamDict];
    [self startLoading];
    if(sender != nil)
        [(UIRefreshControl *)sender endRefreshing];
}

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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(SELF.bmgroup like '%@')",actionSheetPref]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesSubentities:NO];
    rowNum = [context countForFetchRequest:fetchRequest error:nil];
}

#pragma mark - Fetch JSON

- (void)startLoading
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@startRow=%d&category=%@&orderBy=%@",
                                       BIOMODEL_URL,
                                       [Functions contructUrlParamsOnDict:URLparams],
                                       rowNum+1,
                                       [actionSheetDict objectForKey:actionSheetPref],
                                       [sortPrefDict objectForKey:sortPref]]];
    [functions fetchJSONFromURL:url HUDTextMode:(rowNum+1==1?NO:YES) AddHUDToView:self.navigationController.view delegate:self];
}

#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}

#pragma mark - fetch JSON delegate

- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData function:(Functions *)function;
{
    if(function == functions)
    {
        [numberOfObjectsReceived setValue:[NSNumber numberWithInteger:[jsonData count]] forKey:actionSheetPref];
    
        [userDefaults setObject:numberOfObjectsReceived forKey:BM_NUMBEROFOBJECTS];
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
    else if(function == functionOnlineSearch)
    {
        onlineSearchedBiomodels = [NSMutableArray array];
        
        for(NSDictionary *dict in jsonData)
            [onlineSearchedBiomodels addObject:[Biomodel biomodelWithDict:dict inContext:[self managedObjectContext] biomodelGroup:nil]];
        
        UITableView *tableView = self.searchDisplayController.searchResultsTableView;
                
        NSArray *paths = [Functions makeNSIndexPathsFromArray:onlineSearchedBiomodels ForSection:tableView.numberOfSections - 1];
        NSIndexPath *indexPathSearchCell = [NSIndexPath indexPathForRow:0 inSection:tableView.numberOfSections - 1];

        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPathSearchCell] withRowAnimation:UITableViewRowAnimationFade];
        [tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        
    }
    //self.fetchedResultsController = nil;
    //[self.tableView reloadData];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = [[[self fetchedResultsControllerForTableView:tableView] sections] count];
    //Plus One for Online Search
    return (IS_ONLINE_SEARCHED_BIOMODEL)?sections+1:sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(IS_ONLINE_SEARCHED_BIOMODEL_SECTION)
        return onlineSearchedBiomodels?[onlineSearchedBiomodels count]:1;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsControllerForTableView:tableView] sections][section];
    NSInteger numberOfRowsInSection = [sectionInfo numberOfObjects];
    return numberOfRowsInSection;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(IS_ONLINE_SEARCHED_BIOMODEL_SECTION)
        return @"Online";
    
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
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"BiomodelCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"BiomodelCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];
    
    BiomodelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //Register nib files manually for custom cell since search display controller can't load from storyboard
   
    if(cell == nil)
        cell = [[BiomodelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath tableView:tableView];
    return cell;
}

- (void)configureCell:(BiomodelCell *)cell atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    //Online Search
    NSInteger section = indexPath.section;
    if(IS_ONLINE_SEARCHED_BIOMODEL_SECTION && onlineSearchedBiomodels == nil)
    {
            cell.titleLabel.text = @"Press Search Button to Begin";
            cell.titleLabel.textAlignment = NSTextAlignmentCenter;
            cell.detailLabel.text = nil;
            cell.simAppCountLabel.text = nil;
            return;
    }
    
    id object = (IS_ONLINE_SEARCHED_BIOMODEL && onlineSearchedBiomodels != nil)?[onlineSearchedBiomodels objectAtIndex:indexPath.row]:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    
    [self configureCell:cell withObject:object];
    
}

- (void)configureCell:(BiomodelCell *)cell withObject:(id)object
{
    cell.titleLabel.textAlignment = NSTextAlignmentLeft;
    cell.titleLabel.text = [object name];
    
    cell.simAppCountLabel.text = nil;
    
    if(displaySegmentIndex == BIOMODELS_SEGMENT)
    {
        cell.detailLabel.text = [object name];
        
        cell.simAppCountLabel.font = cell.detailTextLabel.font;
        cell.simAppCountLabel.textAlignment = NSTextAlignmentRight;
        cell.simAppCountLabel.textColor = [UIColor darkGrayColor];
        
        __block NSUInteger numberOfSim = 0;
        
        [[object applications] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            numberOfSim += [[obj simulations] count];
        }];
        
        cell.simAppCountLabel.text =  [NSString stringWithFormat:@"| A: %d | S: %d |",[[object applications] count], numberOfSim];
    }
    else if(displaySegmentIndex == APPLICATIONS_SEGMENT)
    {
        cell.detailLabel.text = [NSString stringWithFormat:@"Simulations: %d",[[object simulations] count]];
    }
    else if(displaySegmentIndex == SIMULATIONS_SEGMENT)
    {
        cell.detailLabel.text = [[object application] name];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    BOOL ascending;
    NSString *entityName, *sortKey, *sectionKeyPath;
    NSMutableString *predicateFormat = [NSMutableString stringWithString:@"("];
    
    if([[sortPrefDict objectForKey:sortPref] isEqualToString:DATE_DESC])
    {
        sortKey = @"savedDate";
        ascending = NO;
    }
    else if([[sortPrefDict objectForKey:sortPref] isEqualToString:DATE_ASC])
    {
        sortKey = @"savedDate";
        ascending = YES;
    }
    else if([[sortPrefDict objectForKey:sortPref] isEqualToString:DATE_DESC])
    {
        sortKey = @"name";
        ascending = YES;
    }
    else //if([[sortPrefDict objectForKey:sortPref] isEqualToString:DATE_DESC])
    {
        sortKey = @"name";
        ascending = NO;
    }
    
    switch (displaySegmentIndex) {
            
        case BIOMODELS_SEGMENT:

            entityName = BIOMODEL_ENTITY;
            
            sectionKeyPath = nil;
            
            break;
        case APPLICATIONS_SEGMENT:
            
            entityName = APPLICATION_ENTITY;
            sortKey = [NSString stringWithFormat:@"biomodel.%@",sortKey];
            sectionKeyPath = @"biomodel.bmKey";
            [predicateFormat appendString:@"biomodel."];
            break;
        case SIMULATIONS_SEGMENT:
            
            entityName = SIMULATION_ENTITY;
            sortKey = [NSString stringWithFormat:@"application.biomodel.%@",sortKey];
            sectionKeyPath =  @"application.biomodel.bmKey";
            [predicateFormat appendString:@"application.biomodel."];
            break;
    }
    
    [predicateFormat appendFormat:@"bmgroup like '%@')",actionSheetPref];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    //Set the predicate
    
    
    if(searchString)
        [predicateFormat appendFormat:@" AND (SELF.name contains[c] '%@')",searchString];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
    
    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
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
                indexPath = [NSIndexPath indexPathForRow:rowNum - [[numberOfObjectsReceived objectForKey:actionSheetPref] integerValue] inSection:0];
            else
                indexPath = [NSIndexPath indexPathForRow:0 inSection:oldNumberOfSections];
            
            [Functions scrollToFirstRowOfNewSectionsWithOldNumberOfSections:indexPath tableView:self.tableView];
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    id object = IS_ONLINE_SEARCHED_BIOMODEL_SECTION?[onlineSearchedBiomodels objectAtIndex:indexPath.row]:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    
    BiomodelDetailsViewController *biomodelDetailsViewController = [[BiomodelDetailsViewController alloc] initWithStyle:UITableViewStylePlain];
    [biomodelDetailsViewController setObject:object];
    [self.navigationController pushViewController:biomodelDetailsViewController animated:YES];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView != self.tableView)
        return;
    NSUInteger sections = [[self.fetchedResultsController sections] count];
    if(sections > 0)
        if([[numberOfObjectsReceived objectForKey:actionSheetPref] integerValue] == [[URLparams objectForKey:BM_MAXROWS] integerValue] &&
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
    if(actionSheet == self.actionSheet)
    {
        NSString *btnIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
        if(![btnIndex isEqualToString:@"Cancel"])
        {
            if([btnIndex isEqualToString:[actionSheetPref stringByAppendingString:TICK_MARK]])
                actionSheetPref = [btnIndex stringByReplacingOccurrencesOfString:TICK_MARK withString:@""];
            else
                actionSheetPref = btnIndex;
            
            [userDefaults setObject:actionSheetPref forKey:BM_ACTIONSHEETPREF];
            [userDefaults synchronize];
            [self setOwnerBtnTitle];
            [self initActionSheet];
            [self.tableView setContentOffset:CGPointZero animated:NO]; // Scroll to top
            [self updateNumRow];
            self.fetchedResultsController = nil;
            [self.tableView reloadData];
        }
    }
    
    if(actionSheet == self.optionsActionSheet)
    {
        NSString *btnIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
        if([btnIndex isEqualToString:@"Logout"])
        {
            [LoginViewController logoutFrom:self];
        }
        else if([btnIndex isEqualToString:@"Cancel"]);
        else
        {
            if([btnIndex isEqualToString:[sortPref stringByAppendingString:TICK_MARK]])
                sortPref = [btnIndex stringByReplacingOccurrencesOfString:TICK_MARK withString:@""];
            else
                sortPref = btnIndex;
            
            [userDefaults setObject:sortPref forKey:BM_SORTPREF];
            [userDefaults synchronize];
            [self initOptionsActionSheet];
            [self.tableView setContentOffset:CGPointZero animated:NO]; // Scroll to top
            [Functions deleteAllObjects:BIOMODEL_ENTITY inManagedObjectContext:self.managedObjectContext withOwner:nil];
            self.fetchedResultsController = nil;
            [self.tableView reloadData];
        }
    }
}

- (void)setOwnerBtnTitle
{
    if([actionSheetPref isEqualToString:@"My Models"])
        self.ownerBtn.title = @"My";
    else if([actionSheetPref isEqualToString:@"Educational"])
        self.ownerBtn.title = @"Edu";
    else
        self.ownerBtn.title = actionSheetPref;
}

#pragma mark - Search Delegates
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _searchFetchedResultsController = nil;
    if(displaySegmentIndex == BIOMODELS_SEGMENT && onlineSearchedBiomodels != nil)
    {
        [functionOnlineSearch cancelConnection];
        onlineSearchedBiomodels = nil;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (void)removeOnlineBiomodelSearchedData
{
    if(onlineSearchedBiomodels)
    {
        UITableView *tableView = self.searchDisplayController.searchResultsTableView;
        NSArray *paths = [Functions makeNSIndexPathsFromArray:onlineSearchedBiomodels ForSection:tableView.numberOfSections - 1];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        onlineSearchedBiomodels = nil;
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:self.searchDisplayController.searchResultsTableView.numberOfSections - 1]] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if(displaySegmentIndex == BIOMODELS_SEGMENT)
    {
        UITableView *tableView = self.searchDisplayController.searchResultsTableView;
    
        [self removeOnlineBiomodelSearchedData];
    
        BiomodelCell *cell = (BiomodelCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.searchDisplayController.searchResultsTableView.numberOfSections - 1]];
        cell.titleLabel.text = @"Searching...";
        cell.detailTextLabel.text = @"";
        cell.simAppCountLabel.text = @"";
    
    
        if(functionOnlineSearch == nil)
            functionOnlineSearch = [[Functions alloc] init];
    
        [functionOnlineSearch cancelConnection]; //Kill any previous connection
    
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?bmName=%@&bmId=&category=all&owner=&savedLow=&savedHigh=&startRow=1&maxRows=15&orderBy=date_desc",BIOMODEL_URL,searchBar.text]];
    
        [functionOnlineSearch fetchJSONFromURL:url HUDTextMode:NO AddHUDToView:nil delegate:self];
    }
}

//Reload the main tableView when done with search
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
     [functionOnlineSearch cancelConnection];
    self.searchFetchedResultsController = nil;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
     [functionOnlineSearch cancelConnection];
    self.searchFetchedResultsController = nil;
}

- (IBAction)optionBtnClicked:(id)sender
{
    [self.optionsActionSheet showFromTabBar:self.tabBarController.tabBar];
}

@end

