/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

#import "SimJobController.h"

@interface SimJobController ()
{
    //Class Vars
    Functions *functionsJSON;
    Functions *functionsQuotas;
    NSUInteger numberOfObjectsReceived;
    NSMutableDictionary *URLparams;
    NSMutableData *connectionData;
    NSMutableArray *simJobSections; // JSON objects in sections
    NSMutableArray *filteredSimJobsArr; //Search
    NSMutableArray *simJobs; // Received JSON Objects
    BOOL sortByDate;
    NSUInteger rowNum; //current start row of the data to request
    NSUserDefaults *userDefaults;
    
}
@end

@implementation SimJobController

- (void)initURLParamDict
{
    NSArray *keys=  [NSArray arrayWithObjects:BEGIN_STAMP,
                     END_STAMP,
                     MAXROWS,
                     SERVERID,
                     COMPUTEHOST,
                     SIMID,
                     JOBID,
                     TASKID,
                     HASDATA,
                     @"completed",
                     @"waiting",
                     @"queued",
                     @"dispatched",
                     @"running",
                     @"failed",
                     @"stopped",nil];
    
    NSArray *objects = [NSArray arrayWithObjects:
                        @"",@"",
                        @"10",
                        @"",@"",@"", @"",@"",
                        @"any",
                        @"on",
                        @"",@"",@"",@"",@"",@"",
                        nil];
    
    URLparams = [Functions initURLParamDictWithFileName:SIMJOB_FILTERS_FILE Keys:keys AndObjects:objects];
}

- (void)updateQuota
{
    NSLog(@"Fired");

       NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?startRow=1&maxRows=20&simId=&jobId=&taskId=&hasData=all&waiting=on&dispatched=on&running=on",SIMTASK_URL]];
    [functionsQuotas fetchJSONFromURL:url HUDTextMode:NO AddHUDToView:nil delegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    functionsJSON = [[Functions alloc] init];
    functionsQuotas = [[Functions alloc] init];
    self.navigationItem.title = @"Loading Quotas...";
    [self updateQuota];
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updateQuota) userInfo:nil repeats:YES];

    //Pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(initDictAndstartLoading:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    //setup scopebar of searchbar
    self.searchDisplayController.searchBar.showsScopeBar = NO;
    [self.searchDisplayController.searchBar sizeToFit];
    
    //Load states of bioModel/Date sort
    [self loadPrefs];
    
    [self initDictAndstartLoading:nil];
    
    self.simJobDetailsController = (SimJobDetailsController *)[self.splitViewController.viewControllers lastObject];
}

- (void)loadPrefs
{
    userDefaults  = [NSUserDefaults standardUserDefaults];
    
    //For biomodel/date sort
    sortByDate = [[userDefaults objectForKey:@"sortByDate"] boolValue];
    
    if(sortByDate)
        self.biomodelDateSwapBtn.title = BIOMODEL_SORT;
    else
        self.biomodelDateSwapBtn.title = DATE_SORT;
}

- (void)initDictAndstartLoading:(id)sender
{
    [self initURLParamDict];
    rowNum = 1;
    [self startLoading];
    if(sender != nil)
        [(UIRefreshControl *)sender endRefreshing];
}

- (void)startLoading
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@startRow=%d",SIMTASK_URL,[Functions contructUrlParamsOnDict:URLparams],rowNum]];    
    [functionsJSON fetchJSONFromURL:url HUDTextMode:(rowNum==1?NO:YES) AddHUDToView:self.navigationController.view delegate:self];
}


- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData function:(Functions *)function;
{
    if(function == functionsJSON)
    {
        // Make an empty array
        NSMutableArray *simMutableJobs = [NSMutableArray array];
    
        // Add the objects in the array
        for(NSDictionary *dict in jsonData)
            [simMutableJobs addObject:[[SimJob alloc] initWithDict:dict]];

        numberOfObjectsReceived = [simMutableJobs count];

        if(rowNum == 1)
        {
            simJobs = [NSMutableArray arrayWithArray:simMutableJobs];
            [self breakIntoSectionsbyDate:sortByDate andSimJobArr:simJobs forTableView:self.tableView];
        
        }
        else
        {
            //Update the main array
            [simJobs addObjectsFromArray:simMutableJobs];
        
            //Update the sections array with new sections
        
            NSMutableArray *newSections = [self returnSectionsArrayByDate:sortByDate fromArray:simMutableJobs];
        
            NSUInteger oldNumberOfSections = [self.tableView numberOfSections];
        
            [simJobSections addObjectsFromArray:newSections];
        
            NSUInteger numberOfSections = [self.tableView numberOfSections];
        
            //Add to the tableview
            [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(numberOfSections,[newSections count])] withRowAnimation:UITableViewRowAnimationBottom];
        
            [Functions scrollToFirstRowOfNewSectionsWithOldNumberOfSections:[NSIndexPath indexPathForRow:0 inSection:oldNumberOfSections] tableView:self.tableView];
        }
    }

    if(function == functionsQuotas)
    {
        NSLog(@"Fire End");
        self.navigationItem.title = [NSString stringWithFormat:@"%d/20 Running",jsonData.count];
    }
}
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[hud removeFromSuperview];
	hud = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return [simJobSections count];
    else
        return [simJobSections count] + 1; //for completed/running/stopped buttons
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger currentSection = section;
    if (tableView != self.searchDisplayController.searchResultsTableView)
        currentSection = section - 1;
    
    if(section == 0 && tableView != self.searchDisplayController.searchResultsTableView)
        return 1;
    return [[simJobSections objectAtIndex:currentSection] count];
}
- (void)setCellButtonStyle:(SimJobCell*)cell
{
    UIImage *buttonImage = [[UIImage imageNamed:@"greyButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    [cell.dataBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [cell.dataBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [cell.bioModelBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [cell.bioModelBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *SimJobButtonCellIdentifier = @"SimJobButtonCell";
    
    NSInteger currentSection = indexPath.section;
    //For first cell
    
    //for completed/running/stopped buttons
    if(indexPath.section == 0 && tableView != self.searchDisplayController.searchResultsTableView)
    {
        SimJobButtonCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:SimJobButtonCellIdentifier];
        // Configure the cell...
        if (cell == nil) {
            cell = [[SimJobButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimJobButtonCellIdentifier];
        }
        cell.delegate = self;
        
        //Load button states from disk
        NSNumber *btnState = [[NSUserDefaults standardUserDefaults] objectForKey:@"completed"];
        if(btnState)
            cell.completedBtn.selected = [btnState boolValue];
        
        btnState = [[NSUserDefaults standardUserDefaults] objectForKey:@"running"];
        if(btnState)
            cell.runningBtn.selected = [btnState boolValue];
        
        btnState = [[NSUserDefaults standardUserDefaults] objectForKey:@"stopped"];
        if(btnState)
            cell.stoppedBtn.selected = [btnState boolValue];
        
        return cell;
    }
    if(tableView != self.searchDisplayController.searchResultsTableView)
    {
        currentSection = indexPath.section - 1;
    }
    SimJobCell *cell;
    
    //Register nib files manually for custom cell since search display controller can't load from storyboard
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"SimJobCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"SimJobCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[SimJobCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(simJobs)
    {
        [self setCellButtonStyle:cell];
        SimJob *job = [[simJobSections objectAtIndex:currentSection] objectAtIndex:indexPath.row];
        //Hide Buttons if not needed
        cell.dataBtn.hidden = NO;
        if(![job.hasData boolValue])
            cell.dataBtn.hidden = YES;
        
        cell.bioModelBtn.hidden = NO;
        if(job.bioModelLink.bioModelName == NULL)
            cell.bioModelBtn.hidden = YES;
        
        //Hide buttons if iPad
        if(!IS_PHONE)
        {
            cell.bioModelBtn.hidden = YES;
            cell.dataBtn.hidden = YES;
        }
        
        //Setup labels
        cell.simName.text = job.simName;
        cell.status.text = job.status;
        
        if(job.bioModelLink.simContextName)
            cell.appName.text = job.bioModelLink.simContextName;
        else
            cell.appName.text = @"Unknown";
        
        cell.jobIndex.text = [NSString stringWithFormat:@"%@",job.jobIndex];
        if(sortByDate)
        {
            if(job.bioModelLink.bioModelName)
                cell.startDate.text = job.bioModelLink.bioModelName;
            else
                cell.startDate.text = @"Unknown";
        }
        else
            cell.startDate.text =  [job startDateString];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //Dont display completed/running/stopped buttons in search
    NSInteger currentSection = section;
    if (section == 0 && tableView != self.searchDisplayController.searchResultsTableView)
        return NULL;
    
    if(tableView != self.searchDisplayController.searchResultsTableView)
        currentSection = section - 1;
    
    SimJob *job  = [[simJobSections objectAtIndex:currentSection] objectAtIndex:0];
    
    NSString *title;
    if(sortByDate == YES)
        title = [job startDateString];
    else
        title  = job.bioModelLink.bioModelName;
    
    if(title == NULL)
        title = @"Unknown";
    
    return title;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(numberOfObjectsReceived == [[URLparams objectForKey:@"maxRows"] intValue] && indexPath.section == [simJobSections count] && indexPath.row == [self.tableView numberOfRowsInSection:[simJobSections count]] - 1 && tableView == self.tableView)
    {
        rowNum = rowNum + [[URLparams objectForKey:@"maxRows"] intValue];
        [self startLoading];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(IS_PHONE)
        [self performSegueWithIdentifier:@"showSimJobDetails" sender:nil];
    else
        [self.simJobDetailsController setObject:[[simJobSections objectAtIndex:indexPath.section - 1] objectAtIndex:indexPath.row]];
}

#pragma mark - Class Methods
- (NSMutableArray*)returnSectionsArrayByDate:(BOOL)byDate fromArray:(NSArray*)inputArr
{
    NSMutableArray *keys = [NSMutableArray array];
    
    for(SimJob *job in inputArr)
    {
        NSString *key;
        
        if(byDate)
            key = [job startDateString];
        else
            key = job.bioModelLink.bioModelKey;
        
        if(key != NULL)
            [keys addObject:key];
        else
            [keys addObject:@"Unknown"];
    }
    
    NSSet *uniqueKeysUnordered = [NSSet setWithArray:keys];
    
    NSOrderedSet *uniqueKeys = [[NSOrderedSet alloc] initWithSet:uniqueKeysUnordered];
    
    if(byDate)
    {
        NSArray *sortedKeys = [uniqueKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            dateFormat.dateFormat = DATEFORMAT;
            NSDate *first = [dateFormat dateFromString:obj1];
            NSDate *second = [dateFormat dateFromString:obj2];
            return [second compare:first];
        }];
        
        uniqueKeys = [[NSOrderedSet alloc] initWithArray:sortedKeys];
    }
    
    NSMutableArray *sections = [NSMutableArray array];
    
    for(NSString *key in uniqueKeys)
        [sections addObject:[NSMutableArray array]];
    
    for(SimJob *job in inputArr)
    {
        NSString *key;
        
        if(byDate)
            key = [job startDateString];
        else
            key = job.bioModelLink.bioModelKey;
        
        if(key == NULL)
            key = @"Unknown";
        
        for(NSString *itrkey in uniqueKeys)
        {
            if([key isEqualToString:itrkey])
            {
                NSMutableArray *section = [sections objectAtIndex:[uniqueKeys indexOfObject:key]];
                [section addObject:job];
                break;
            }
        }
    }
    return sections;
}
- (void)breakIntoSectionsbyDate:(BOOL)byDate andSimJobArr:(NSArray*)currentSimJobs forTableView:(UITableView*)tableView
{
    simJobSections = [self returnSectionsArrayByDate:byDate fromArray:currentSimJobs];
    [tableView reloadData];
}

- (IBAction)bioModelDateSwap:(id)sender
{
    UIBarButtonItem *sortButton = (UIBarButtonItem*)sender;
    
    if([sortButton.title isEqualToString:@"Date"])
    {
        sortButton.title = BIOMODEL_SORT;
        sortByDate = YES;
    }
    else if([sortButton.title isEqualToString:@"BioModel"])
    {
        sortButton.title = DATE_SORT;
        sortByDate = NO;
    }
    
    [userDefaults setObject:[NSNumber numberWithBool:sortByDate] forKey:@"sortByDate"];
    [userDefaults synchronize];
    [self breakIntoSectionsbyDate:sortByDate andSimJobArr:simJobs forTableView:self.tableView];
}

- (void)updatDataOnBtnPressedWithButtonTag:(int)tag AndButtonActive:(BOOL)active
{
    
    if(active)
    {
        if(tag == COMPLETED_BTN)
        {
            [URLparams setObject:@"on" forKey:@"completed"];
        }
        else if (tag == RUNNING_BTN)
        {
            [URLparams setObject:@"on" forKey:@"waiting"];
            [URLparams setObject:@"on" forKey:@"queued"];
            [URLparams setObject:@"on" forKey:@"dispatched"];
            [URLparams setObject:@"on" forKey:@"running"];
        }
        else if (tag == STOPPED_BTN)
        {
            [URLparams setObject:@"on" forKey:@"stopped"];
            [URLparams setObject:@"on" forKey:@"failed"];
        }
    }
    else
    {
        if(tag == COMPLETED_BTN)
        {
            [URLparams setObject:@"" forKey:@"completed"];
        }
        else if (tag == RUNNING_BTN)
        {
            [URLparams setObject:@"" forKey:@"waiting"];
            [URLparams setObject:@"" forKey:@"queued"];
            [URLparams setObject:@"" forKey:@"dispatched"];
            [URLparams setObject:@"" forKey:@"running"];
        }
        else if (tag == STOPPED_BTN)
        {
            [URLparams setObject:@"" forKey:@"stopped"];
            [URLparams setObject:@"" forKey:@"failed"];
        }
    }
    
    //Write params to disk
    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:SIMJOB_FILTERS_FILE];
    [URLparams writeToFile:plistPath atomically:YES];
    rowNum = 1;
    [self startLoading];
}
//Needed to set height of search display controller properly.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Height of cell for toggle buttons
    if(indexPath.section == 0 && tableView != self.searchDisplayController.searchResultsTableView)
        return 38.0f;
    //Height of normal cells
    return 86.0f;
}

#pragma mark - Search Delegates
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self initSearchWithSearchText:searchText];
}

- (void)initSearchWithSearchText:(NSString *)searchText
{
    
    [filteredSimJobsArr removeAllObjects];
    NSString *searchScopeProperty;
    NSInteger scopeIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    if(scopeIndex == SIMULATION_SCOPE)
        searchScopeProperty = @"simName";
    else if(scopeIndex == SIMKEY_SCOPE)
        searchScopeProperty = @"simKey";
    else if(scopeIndex == APPLICATION_SCOPE)
        searchScopeProperty = @"bioModelLink.simContextName";
    else if(scopeIndex == BIOMODEL_SCOPE)
        searchScopeProperty = @"bioModelLink.bioModelName";
    if(searchText == NULL)
        searchText = self.searchDisplayController.searchBar.text;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.%@ contains[c] %@",searchScopeProperty,searchText];
    filteredSimJobsArr = [NSMutableArray arrayWithArray:[simJobs filteredArrayUsingPredicate:predicate]];
    [self breakIntoSectionsbyDate:sortByDate andSimJobArr:filteredSimJobsArr forTableView:self.searchDisplayController.searchResultsTableView];
    
}

//Reload the main tableView when done with search
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    [self breakIntoSectionsbyDate:sortByDate andSimJobArr:simJobs forTableView:self.tableView];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self breakIntoSectionsbyDate:sortByDate andSimJobArr:simJobs forTableView:self.tableView];
}
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self initSearchWithSearchText:NULL];
}

#pragma mark - Filter View

- (void)SimJobsFiltersControllerDidFinish:(SimJobsFiltersController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView setContentOffset:CGPointZero animated:NO];
    [self initDictAndstartLoading:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSimJobsFilters"])
    {
        [[segue destinationViewController] setDelegate:self];
    }
    if([[segue identifier] isEqualToString:@"showSimJobDetails"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [[segue destinationViewController] setObject:[[simJobSections objectAtIndex:indexPath.section - 1] objectAtIndex:indexPath.row]];
    }
}

@end
