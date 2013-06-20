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
    NSMutableDictionary *URLparams;
    NSMutableData *connectionData;
    NSMutableDictionary *simJobSections; // JSON objects in sections
    NSArray *keyArray; // Keys of the Sections
    NSMutableArray *filteredSimJobsArr; //Search
    NSArray *simJobs; // Received JSON Objects
    BOOL sortByDate;
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
                        @"20",
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
    
    [self startLoading];

}

- (void)startLoading
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SIMTASK_URL,[self contructUrlParamsOnDict:URLparams]]];
    connectionData = [NSMutableData data];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlReq  delegate:self];
    [connection start];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Downloading...";
}

#pragma mark - NSURLConnectionDelegete

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	expectedLength = [response expectedContentLength];
	currentLength = 0;
	HUD.mode = MBProgressHUDModeDeterminate;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    currentLength += [data length];
    HUD.progress = currentLength / (float)expectedLength;
    [connectionData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // Save the received JSON array inside an NSArray
    NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:connectionData options:kNilOptions error:nil];
    
    // Make an empty array with size equal to number of objects received
    NSMutableArray *simMutableJobs = [NSMutableArray arrayWithCapacity:[jsonData count]];
    
    // Add the objects in the array
    for(NSDictionary *dict in jsonData)
        [simMutableJobs addObject:[[SimJob alloc] initWithDict:dict]];
        
    simJobs = [NSArray arrayWithArray:simMutableJobs];
    
    [self breakIntoSectionsbyDate:NO andSimJobArr:simJobs forTableView:self.tableView];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	HUD.mode = MBProgressHUDModeCustomView;
    HUD.dimBackground = NO;
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
        return [keyArray count];
    else
        return [keyArray count]+1; //for completed/running/stopped buttons 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger currentSection = section;
    if (tableView != self.searchDisplayController.searchResultsTableView)
        currentSection = section - 1;
    
    if(section == 0 && tableView != self.searchDisplayController.searchResultsTableView)
        return 1;
    return [[simJobSections objectForKey:[keyArray objectAtIndex:currentSection]] count];
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
        SimJob *job = [[simJobSections objectForKey:[keyArray objectAtIndex:currentSection]] objectAtIndex:indexPath.row];
    
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
    
    NSString *key = [keyArray objectAtIndex:currentSection];
   
    if([key isEqualToString:@"Unknown"] || sortByDate == YES)
        return key;
    
    SimJob *job = [[simJobSections objectForKey:key] objectAtIndex:0];
    return job.bioModelLink.bioModelName;
    
}

#pragma mark - Class Methods

- (void)breakIntoSectionsbyDate:(BOOL)byDate andSimJobArr:(NSArray*)currentSimJobs forTableView:(UITableView*)tableView
{
    sortByDate = byDate;
    
    NSMutableArray *keys = [NSMutableArray array];
    //For sort by date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"EEEE',' d MMMM yyyy";
    
    for(SimJob *job in currentSimJobs)
    {
        NSString *key;
        
        if(byDate)
        {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[job.startdate doubleValue]/1000];
            key = [dateFormat stringFromDate:date];
        }
        else
            key = job.bioModelLink.bioModelKey;
        
        if(key != NULL)
            [keys addObject:key];
        else
            [keys addObject:@"Unknown"];
    }
    
    NSSet *uniqueKeys = [NSSet setWithArray:keys];
    
    simJobSections = [NSMutableDictionary dictionary];
    
    for(NSString *key in uniqueKeys)
        [simJobSections setObject:[NSMutableArray array] forKey:key];
    
    for(SimJob *job in currentSimJobs)
    {
        NSString *key;
        if(byDate)
        {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[job.startdate doubleValue]/1000];
            key = [dateFormat stringFromDate:date];
        }
        else
            key = job.bioModelLink.bioModelKey;
        
        if(key == NULL)
            key = @"Unknown";
        
        for(NSString *itrkey in simJobSections)
        {
            if([key isEqualToString:itrkey])
            {
                NSMutableArray *section = [simJobSections objectForKey:itrkey];
                [section addObject:job];
                break;
            }
        }
    }
   // NSLog(@"%@",simJobSections);
    keyArray = [simJobSections allKeys];
    [tableView reloadData];
}

- (IBAction)bioModelDateSwap:(id)sender
{
    UISegmentedControl *sortButton = (UISegmentedControl*)sender;
    
   if(sortButton.selectedSegmentIndex == BIOMODEL_SORT)
       [self breakIntoSectionsbyDate:NO andSimJobArr:simJobs forTableView:self.tableView];
    
   else if(sortButton.selectedSegmentIndex == DATE_SORT)
       [self breakIntoSectionsbyDate:YES andSimJobArr:simJobs forTableView:self.tableView];
    
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
    [self breakIntoSectionsbyDate:NO andSimJobArr:filteredSimJobsArr forTableView:self.searchDisplayController.searchResultsTableView];
}
//Reload the main tableView when done with search
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    [self breakIntoSectionsbyDate:NO andSimJobArr:simJobs forTableView:self.tableView];
}
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self initSearchWithSearchText:NULL];
}



@end
