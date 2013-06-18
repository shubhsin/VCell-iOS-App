//
//  FirstViewController.m
//  VCell
//
//  Created by Aciid on 09/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "SimJobController.h"

#define BIOMODEL_SORT 0
#define DATE_SORT 1

@interface SimJobController ()
{
    NSMutableData *connectionData;
    NSMutableArray *simJobs; // Received JSON Objects
    NSMutableDictionary *simJobSections; // JSON objects in sections
    NSArray *keyArray; // Keys of the Sections
    BOOL sortByDate;
}
@end

@implementation SimJobController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?submitLow=&submitHigh=&maxRows=10&serverId=&computeHost+value3D=&simId=&jobId=&taskId=&hasData=all&completed=on",SIMTASK_URL]];
    connectionData = [NSMutableData data];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlReq  delegate:self];
    [connection start]; 
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [connectionData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Save the received JSON array inside an NSArray
    NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:connectionData options:kNilOptions error:nil];
       
    // Make an empty array with size equal to number of objects received
    simJobs = [NSMutableArray arrayWithCapacity:[jsonData count]];
    
    // Add the objects in the array
    for(NSDictionary *dict in jsonData)
        [simJobs addObject:[[SimJob alloc] initWithDict:dict]];
    
    [self breakIntoSectionsbyDate:NO];
    
    
}

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
        SimJob *job = [[simJobSections objectForKey:[keyArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
        cell.simName.text = job.simName;
        cell.message.text = job.message;
        cell.htcJobID.text =  [NSString stringWithFormat:@"%@",job.htcJobId];
        cell.status.text = job.status;
        cell.simKey.text = job.simKey;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[job.startdate doubleValue]/1000];
        cell.startDate.text =  [NSString stringWithFormat:@"%@",date];
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

- (IBAction)bioModelDateSwap:(id)sender
{
    UISegmentedControl *sortButton = (UISegmentedControl*)sender;
    
   if(sortButton.selectedSegmentIndex == BIOMODEL_SORT)
       [self breakIntoSectionsbyDate:NO];
    
   else if(sortButton.selectedSegmentIndex == DATE_SORT)
       [self breakIntoSectionsbyDate:YES];
    
}

@end
