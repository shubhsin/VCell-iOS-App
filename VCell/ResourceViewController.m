//
//  ResourceViewController.m
//  VCell_14
//
//  Created by Ankit Agarwal on 11/06/14.
//  Copyright (c) 2014 ankit. All rights reserved.
//

#import "ResourceViewController.h"
#import "SimJobTableViewCell.h"
#import "SimJob.h"

@interface ResourceViewController ()
{
    Functions *fetchSimJobRunning;
    int rowNumRunning;
    NSMutableArray *simJobsRunning;

    Functions *fetchSimJobQueue;
    int rowNumJobQueue;
    NSMutableArray *simJobsQueue;
}

@end

@implementation ResourceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    rowNumJobQueue = 1;
    rowNumRunning = 1;
    
    simJobsRunning = [NSMutableArray array];
    simJobsQueue = [NSMutableArray array];

    fetchSimJobRunning = [[Functions alloc] init];
    fetchSimJobQueue = [[Functions alloc] init];
    
    [self startLoading];
}

- (void)startLoading
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?submitLow=&submitHigh=&maxRows=10&serverId=&computeHost+value%%3D=&simId=&jobId=&taskId=&hasData=all&dispatched=on&running=on&startRow=%d",SIMTASK_URL,rowNumRunning]];
    [fetchSimJobRunning fetchJSONFromURL:url HUDTextMode:(rowNumRunning==1?NO:YES) AddHUDToView:self.tableViewRunning delegate:self];
   url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?submitLow=&submitHigh=&maxRows=10&serverId=&computeHost+value%%3D=&simId=&jobId=&taskId=&hasData=all&waiting=on&queued=on&startRow=%d",SIMTASK_URL,rowNumRunning]];
    [fetchSimJobQueue fetchJSONFromURL:url HUDTextMode:(rowNumJobQueue==1?NO:YES) AddHUDToView:self.tableViewQueue delegate:self];
}


- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData function:(Functions *)function
{
    if(function == fetchSimJobRunning)
    {
        // Add the objects in the array
        for(NSDictionary *dict in jsonData)
            [simJobsRunning addObject:[[SimJob alloc] initWithDict:dict]];
        
        [self.tableViewRunning reloadData];
    }
    else if(function == fetchSimJobQueue)
    {
        // Add the objects in the array
        for(NSDictionary *dict in jsonData)
            [simJobsQueue addObject:[[SimJob alloc] initWithDict:dict]];
        
        [self.tableViewQueue reloadData];
    }
    
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tableViewRunning)
    {
        return simJobsRunning.count;
    }
    else //if(tableView == self.tableViewQueue)
    {
        return simJobsQueue.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimJob *simJob;
    
    if(tableView == self.tableViewRunning)
    {
        simJob = [simJobsRunning objectAtIndex:indexPath.row];
    }
    else //if(tableView == self.tableViewQueue)
    {
        simJob = [simJobsQueue objectAtIndex:indexPath.row];
    }
    
    SimJobTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.simNameLabel.text = simJob.simName;
    cell.simStatusLabel.text = simJob.status;
    cell.simUserLabel.text = simJob.userName;
    
    cell.simDataBtn.enabled = [simJob.hasData boolValue];
    
    if([simJob.status isEqualToString:@"running"] || [simJob.status isEqualToString:@"dispatched"] || [simJob.status isEqualToString:@"queued"] || [simJob.status isEqualToString:@"waiting"])
        cell.simStartBtn.titleLabel.text = @"Stop";
    else
        cell.simStartBtn.titleLabel.text = @"Start";
    
    if([simJob.status isEqualToString:@"running"])
        cell.simStatusLabel.text = [NSString stringWithFormat:@"%.0f%% Completed",[simJob.progressValue floatValue]*100];
    
    [cell.simStatusLabel sizeToFit];

    
    return cell;
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == self.tableViewRunning) {
        return @"Running";
    }
    else //if(tableView == self.tableViewQueue)
    {
        return @"Queued";
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
