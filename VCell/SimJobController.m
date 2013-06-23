//
//  FirstViewController.m
//  VCell
//
//  Created by Aciid on 09/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "SimJobController.h"



@interface SimJobController ()
{
    //HUD Variables
    MBProgressHUD *HUD;
    long long expectedLength;
	long long currentLength;
    
    //Class Vars
    NSUInteger numberOfObjectsReceived;
    NSMutableDictionary *URLparams;
    NSMutableData *connectionData;
    NSMutableArray *simJobSections; // JSON objects in sections
    NSMutableArray *filteredSimJobsArr; //Search
    NSMutableArray *simJobs; // Received JSON Objects
    BOOL sortByDate;
    NSUInteger rowNum; //current start row of the data to request
}
@end

@implementation SimJobController

- (NSString*)contructUrlParamsOnDict:(NSDictionary*)dict
{ 
    NSMutableString *params = [NSMutableString stringWithString:@"?"];
    
    for(NSString *key in dict)
        [params appendFormat:@"%@=%@&",key,[dict objectForKey:key]];
    
//    NSLog(@"%@",params);
    return params;
}
- (void)initURLParamDict
{
    NSArray *keys = [NSArray arrayWithObjects:
                     @"submitLow",
                     @"submitHigh",
                     @"maxRows",
                     @"serverId",
                     @"computeHost+value%3D",
                     @"simId",
                     @"jobId",
                     @"taskId",
                     @"hasData",
                     @"completed",
                     @"waiting",
                     @"queued",
                     @"dispatched",
                     @"running",
                     @"failed",
                     @"stopped",
                     nil];
    
    NSArray *objects = [NSArray arrayWithObjects:
                        @"",@"",
                        [NSNumber numberWithInteger:10],
                        @"",@"",@"", @"",@"",
                        @"any",
                        @"on",
                        @"",@"",@"",@"",@"",@"",
                        nil];
    
    URLparams = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchDisplayController.searchBar.showsScopeBar = NO;
    [self.searchDisplayController.searchBar sizeToFit];
    [self initURLParamDict];
    sortByDate = NO;
    rowNum = 1;
    [self startLoading];
}

- (void)startLoading
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@startRow=%d",SIMTASK_URL,[self contructUrlParamsOnDict:URLparams],rowNum]];
    NSLog(@"%@",url);
    connectionData = [NSMutableData data];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlReq  delegate:self];
    [connection start];
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.delegate = self;
    if(rowNum == 1)
    {
        HUD.dimBackground = YES;
        HUD.labelText = @"Downloading...";
    }
    else
    {
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = @"Downloading...";
        HUD.margin = 10.f;
        HUD.yOffset = 150.f;
        HUD.userInteractionEnabled = NO;
    }
}

#pragma mark - NSURLConnectionDelegete

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if(rowNum == 1)
    {
        expectedLength = [response expectedContentLength];
        currentLength = 0;
        HUD.mode = MBProgressHUDModeDeterminate;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(rowNum == 1)
    {
        currentLength += [data length];
        HUD.progress = currentLength / (float)expectedLength;
    }
    [connectionData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // Save the received JSON array inside an NSArray
    NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:connectionData options:kNilOptions error:nil];
    
    // Make an empty array with size equal to number of objects received
    NSMutableArray *simMutableJobs = [NSMutableArray array];
    
    // Add the objects in the array
    for(NSDictionary *dict in jsonData)
        [simMutableJobs addObject:[[SimJob alloc] initWithDict:dict]];
    
    numberOfObjectsReceived = [simMutableJobs count];
    
    if(rowNum == 1)
    {
        simJobs = [NSMutableArray arrayWithArray:simMutableJobs];
        [self breakIntoSectionsbyDate:sortByDate andSimJobArr:simJobs forTableView:self.tableView];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.dimBackground = NO;
    
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
    
    HUD.labelText = @"Done!";
    [HUD hide:YES afterDelay:1];



}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[HUD hide:YES];
}

#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
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
  //  NSLog(@"%@",simJobSections);
    [tableView reloadData];
}

- (IBAction)bioModelDateSwap:(id)sender
{
    UISegmentedControl *sortButton = (UISegmentedControl*)sender;

   if(sortButton.selectedSegmentIndex == BIOMODEL_SORT)
       sortByDate = NO;
   else if(sortButton.selectedSegmentIndex == DATE_SORT)
       sortByDate = YES;

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
        rowNum = 1;
        [self startLoading];
     
}
 //Needed to set height of search display controller properly.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && tableView != self.searchDisplayController.searchResultsTableView)
        return 38.0f;
    return 112.0f;
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

- (IBAction)addMoreCells:(id)sender
{
    rowNum = rowNum + [[URLparams objectForKey:@"maxRows"] intValue];
    [self startLoading];
}
@end
