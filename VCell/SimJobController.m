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
    
    
    NSMutableDictionary *filteredSimJobs; //used to hold search bar results
    NSMutableDictionary *simJobSections; // JSON objects in sections
    NSMutableDictionary *currentSimJobSectons; // points to search results or whole content
    
    NSArray *keyArray; // Keys of the Sections
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
    
    NSLog(@"%@",params);
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
- (void)setUpBtns
{

    UIButton *button;
    button = (UIButton *)[self.view viewWithTag:COMPLETED_BTN];
    button.titleLabel.textColor = [UIColor whiteColor];
    
    button = (UIButton *)[self.view viewWithTag:STOPPED_BTN];
    button.titleLabel.textColor = [UIColor colorWithRed:71/255.0 green:84/255.0 blue:255/255.0 alpha:1.0];
    
    button = (UIButton *)[self.view viewWithTag:RUNNING_BTN];
    button.titleLabel.textColor = [UIColor colorWithRed:71/255.0 green:84/255.0 blue:255/255.0 alpha:1.0];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpBtns];
    
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
    
    [self breakIntoSectionsbyDate:NO];
    
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
    return [keyArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[simJobSections objectForKey:[keyArray objectAtIndex:section]] count];
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
    SimJobCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[SimJobCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
   
    if(simJobs)
    {
        [self setCellButtonStyle:cell];
        
        SimJob *job = [[simJobSections objectForKey:[keyArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
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
    NSString *key = [keyArray objectAtIndex:section];
   
    if([key isEqualToString:@"Unknown"] || sortByDate == YES)
        return key;
    
    SimJob *job = [[simJobSections objectForKey:key] objectAtIndex:0];
    return job.bioModelLink.bioModelName;
    
}

#pragma mark - Class Methods

- (void)breakIntoSectionsbyDate:(BOOL)byDate 
{
    sortByDate = byDate;
    
    NSMutableArray *keys = [NSMutableArray array];
    //For sort by date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"EEEE',' d MMMM yyyy";
    
    for(SimJob *job in simJobs)
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
    
    for(SimJob *job in simJobs)
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
    keyArray = [simJobSections allKeys];
    [self.tableView reloadData];
}

- (IBAction)bioModelDateSwap:(id)sender
{
    UISegmentedControl *sortButton = (UISegmentedControl*)sender;
    
   if(sortButton.selectedSegmentIndex == BIOMODEL_SORT)
       [self breakIntoSectionsbyDate:NO];
    
   else if(sortButton.selectedSegmentIndex == DATE_SORT)
       [self breakIntoSectionsbyDate:YES];
    
}

- (IBAction)optionsBtnPressed:(id)sender
{
    UIButton *button = (UIButton*)sender;
    
    
    //Imitate toggle behavior for the buttons. 
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        
        BOOL active;
        //toggle the switch
        if(button.selected)
        {
            button.highlighted = NO;
            button.selected = NO;
            button.titleLabel.textColor = [UIColor colorWithRed:71/255.0 green:84/255.0 blue:255/255.0 alpha:1.0];
            active = NO;
        }
        else
        {
            button.highlighted = YES;
            button.selected = YES;
            button.titleLabel.textColor = [UIColor whiteColor];
            active = YES;
        }
        
        //construct the URL params
        if(active)
        {
            if(button.tag == COMPLETED_BTN)
            {
                [URLparams setObject:@"on" forKey:@"completed"];
            }
            else if (button.tag == RUNNING_BTN)
            {
                [URLparams setObject:@"on" forKey:@"waiting"];
                [URLparams setObject:@"on" forKey:@"queued"];
                [URLparams setObject:@"on" forKey:@"dispatched"];
                [URLparams setObject:@"on" forKey:@"running"];
            }
            else if (button.tag == STOPPED_BTN)
            {
                [URLparams setObject:@"on" forKey:@"stopped"];
                [URLparams setObject:@"on" forKey:@"failed"];
            }
        }
        else
        {
            if(button.tag == COMPLETED_BTN)
            {
                [URLparams setObject:@"" forKey:@"completed"];
            }
            else if (button.tag == RUNNING_BTN)
            {
                [URLparams setObject:@"" forKey:@"waiting"];
                [URLparams setObject:@"" forKey:@"queued"];
                [URLparams setObject:@"" forKey:@"dispatched"];
                [URLparams setObject:@"" forKey:@"running"];
            }
            else if (button.tag == STOPPED_BTN)
            {
                [URLparams setObject:@"" forKey:@"stopped"];
                [URLparams setObject:@"" forKey:@"failed"];
            }
        }
        
        [self startLoading];
        
        
    }];
}

#pragma mark - Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [filteredSimJobs removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.simName contains[c] %@",searchText];
    filteredSimJobs = [NSMutableArray arrayWithArray:[simJobs filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles]
      objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}



@end
