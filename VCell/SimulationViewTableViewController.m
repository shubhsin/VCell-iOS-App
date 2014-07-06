//
//  SimulationViewTableViewController.m
//  VCell_14
//
//  Created by Aciid on 04/06/14.
//  Copyright (c) 2014 ankit. All rights reserved.
//

#import "SimulationViewTableViewController.h"
#import "SimulationViewTableViewCell.h"
#import "SimViewQuotaTableViewCell.h"
#import "SimJobTableViewController.h"

@interface SimulationViewTableViewController ()
{
    Functions *fetchSimJobFunc;
    int rowNum;
    NSMutableDictionary *simJobs; // Key: simKey , Value: SimJobs
    NSMutableOrderedSet *simKeys; // simKeys with order preserved.
    BOOL isLoading;
}

@end

@implementation SimulationViewTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    rowNum = 1; //Initalize rowNum to 1 initially
    simJobs = [NSMutableDictionary dictionary];
    simKeys = [NSMutableOrderedSet orderedSet];
    fetchSimJobFunc = [[Functions alloc] init]; //For fetching simJobs
    [self startLoading]; //Start the fetching 
}

- (void)startLoading
{
    isLoading = YES;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?submitLow=&submitHigh=&maxRows=10&serverId=&computeHost+value%%3D=&simId=&jobId=&taskId=&hasData=all&waiting=on&queued=on&dispatched=on&running=on&completed=on&failed=on&stopped=on&startRow=%d",SIMTASK_URL,rowNum]];
   // ALog(@"%@",url);
    [fetchSimJobFunc fetchJSONFromURL:url HUDTextMode:(rowNum==1?NO:YES) AddHUDToView:self.navigationController.view delegate:self];
}

- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData function:(Functions *)function
{
    if(function == fetchSimJobFunc)
    {
        // Make an empty array
        NSMutableArray *simMutableJobs = [NSMutableArray array];
        
        // Add the objects in the array
        for(NSDictionary *dict in jsonData)
            [simMutableJobs addObject:[[SimJob alloc] initWithDict:dict]];
        
        //Get unique simKeys

        [simKeys addObjectsFromArray:[simMutableJobs valueForKey:@"simKey"]];
        
        [simMutableJobs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           
            SimJob *simJobObject = (SimJob *)obj;
            
            for(int i=0;i<simKeys.count;i++)
            {
                if([simJobObject.simKey isEqualToString:[simKeys objectAtIndex:i]])
                {
                    NSMutableArray *simJobsOfThisKey = [simJobs objectForKey:simJobObject.simKey];
                    if(simJobsOfThisKey == nil)
                        simJobsOfThisKey = [NSMutableArray array];
                    [simJobsOfThisKey addObject:simJobObject];
                    [simJobs setValue:simJobsOfThisKey forKey:simJobObject.simKey];
                }
            }
            
        }];
        
        // load more data if first request doesnt fill up the screen
        if(simKeys.count < 10 && simMutableJobs.count != 0)
        {
            rowNum = rowNum + 10;
            [self startLoading];
        }
        
        [self.tableView reloadData];
        isLoading = NO;
    }
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(simKeys.count > 0 && !isLoading){
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height) {
            rowNum = rowNum + 10;
            [self startLoading];
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [simKeys count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
        return 30.0f;
    return 55.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        SimViewQuotaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuotaCell" forIndexPath:indexPath];
        cell.quotaMaxLabel.text = @"1";
        cell.quotaRunningLabel.text = @"11";
        cell.quotaWaitingLabel.text = @"22";
        return cell;
    }
    else
    {
        SimulationViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        SimJob *simJob = [[simJobs objectForKey:[simKeys objectAtIndex:indexPath.row - 1]] objectAtIndex:0];
        cell.simName.lineBreakMode = NSLineBreakByWordWrapping;
        cell.simName.numberOfLines = 0;
        cell.simName.text = simJob.simName;
        cell.numJobs.text = [simJob.scanCount stringValue];
        cell.simStatus.text = [self calculateSimulationStatus:[simJobs objectForKey:[simKeys objectAtIndex:indexPath.row - 1]]];
        
        return cell;
    }
    return nil;
}

- (NSString*)calculateSimulationStatus:(NSArray*)jobs
{
    NSString *status;
    
    __block NSInteger running = 0, completed = 0;
    
    [jobs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SimJob *simjob = obj;
        if([simjob.status isEqualToString:@"running"])
            running++;
        if([simjob.status isEqualToString:@"completed"])
            completed++;
    }];
    
    NSInteger numJobs = [[[jobs objectAtIndex:0] scanCount] integerValue];
    if(completed == numJobs)
        status = @"Completed";
    else
        status = [NSString stringWithFormat:@"%.0f%% Running \n %.0f%% Completed",(running/(float)numJobs)*100,(completed/(float)numJobs)*100];
    
    return status;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row != 0)
    {
        [self performSegueWithIdentifier:@"ShowSimJobs" sender:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([[segue identifier] isEqualToString:@"ShowSimJobs"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [[segue destinationViewController] setObject:[simJobs objectForKey:[simKeys objectAtIndex:indexPath.row - 1]]];
    }
    
}


@end
