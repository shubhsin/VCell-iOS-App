/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

#import "SimJobDetailsController.h"

@interface SimJobDetailsController ()
{
    SimJob *simJob;
}
@end

@implementation SimJobDetailsController

- (void)setObject:(SimJob *)object
{
    simJob = object;
    if(!IS_PHONE)
        [self setUpCells];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshSimJob:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    if(IS_PHONE)
        [self setUpCells];
}

- (void)refreshSimJob:(id)sender
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?simId=%@&jobId=%@&taskId=%@&completed=on&dispatched=on&failed=on&queued=on&running=on&stopped=on&waiting=on",SIMTASK_URL,simJob.simKey,simJob.jobIndex,simJob.taskId]];
    [[[Functions alloc] init] fetchJSONFromURL:url HUDTextMode:NO AddHUDToView:self.navigationController.view delegate:self];
    [(UIRefreshControl *)sender endRefreshing];
}

- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData function:(Functions *)function
{
    SimJob *newSimJob = [[SimJob alloc] initWithDict:[jsonData objectAtIndex:0]];
    [self loadNewSimJob:newSimJob];
}

- (void)loadNewSimJob:(SimJob*)newSimJob
{
    simJob = newSimJob;
    [self setUpCells];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)setUpCells
{
    //section 0
    if([simJob.schedulerStatus isEqualToString:@"stopped"] || [simJob.schedulerStatus isEqualToString:@"failed"] ||
       [simJob.schedulerStatus isEqualToString:@"completed"])
        self.startStopSim.textLabel.text = STARTSIMULATION;
    else
        self.startStopSim.textLabel.text = STOPSIMULATION;
    
    //section 1
    self.simKey.detailTextLabel.text = simJob.simKey;
    self.simName.detailTextLabel.text = simJob.simName;
    self.status.detailTextLabel.text = simJob.status;
    self.startDate.detailTextLabel.text = [simJob startDateString];
    self.msg.detailTextLabel.text = simJob.message;
    //section 2
    self.simContextKey.detailTextLabel.text = simJob.bioModelLink.simContextKey;
    self.simContextBranch.detailTextLabel.text = simJob.bioModelLink.simContextBranchId;
    self.simContextName.detailTextLabel.text = simJob.bioModelLink.simContextName;
    
    //section 3
    self.bioModelKey.detailTextLabel.text = simJob.bioModelLink.bioModelKey;
    self.bioModelBranch.detailTextLabel.text = simJob.bioModelLink.bioModelBranchId;
    self.bioModelName.detailTextLabel.text = simJob.bioModelLink.bioModelName;
    
    //section 4
    self.username.detailTextLabel.text = simJob.userName;
    self.userKey.detailTextLabel.text = simJob.userKey;
    self.jobId.detailTextLabel.text = [simJob.jobIndex description];
    self.taskId.detailTextLabel.text = [simJob.taskId description];
    self.htcJobId.detailTextLabel.text = simJob.htcJobId;
    
    //section 5
    self.site.detailTextLabel.text = simJob.site;
    self.computeHost.detailTextLabel.text = simJob.computeHost;
    self.schStatus.detailTextLabel.text = simJob.schedulerStatus;
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.detailTextLabel.text == nil)
        cell.detailTextLabel.text = @"Unknown";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) //0th section contains buttons
    {
        if(indexPath.row == 0) // View Data
        {
            if([simJob.hasData intValue] == 1)
                [self performSegueWithIdentifier:@"viewData" sender:self];
            else
                [[[UIAlertView alloc] initWithTitle:@"No Data" message:@"This simulation has no data." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        else if(indexPath.row == 1) // View Parent
        {
            if([self isFromBiomodelTab]) //If Navigation is from biomodel tab, pop two view controllers for parent
            {
                NSArray *viewControllers = [self.navigationController viewControllers];
                [self.navigationController popToViewController:[viewControllers objectAtIndex:[viewControllers count] - 3] animated:YES];
            }
            else
            {
                BiomodelDetailsViewController *biomodelDetailsViewController = [[BiomodelDetailsViewController alloc] initWithStyle:UITableViewStylePlain];
                [biomodelDetailsViewController setObject:simJob];
                [self.navigationController pushViewController:biomodelDetailsViewController animated:YES];
            }
        }
        else if(indexPath.row == 2) //Start stop simulation
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            NSURL *url;
            if([self.startStopSim.textLabel.text isEqualToString:STARTSIMULATION])
            {
               url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/simulation/%@/startSimulation",BIOMODEL_URL,simJob.bioModelLink.bioModelKey,simJob.simKey]];
            }
            else
            {
                 url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/simulation/%@/stopSimulation",BIOMODEL_URL,simJob.bioModelLink.bioModelKey,simJob.simKey]];
            }
            
            NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:url];
            [urlReq setHTTPMethod:@"POST"];
       
            MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            HUD.mode = MBProgressHUDModeText;
            HUD.labelText = @"Working...";
            HUD.margin = 10.f;
            HUD.yOffset = 150.f;
            HUD.userInteractionEnabled = YES;
            
            [NSURLConnection sendAsynchronousRequest:urlReq queue:[NSOperationQueue mainQueue]
            completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
            {
                SimJob *newSimJob = [[SimJob alloc] initWithDict:[[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil] objectAtIndex:0]];
                [self loadNewSimJob:newSimJob];
                [HUD hide:YES];
            }];
            
        }
    }
    else
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Details" message:cell.detailTextLabel.text delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"viewData"])
    {
        [[segue destinationViewController] setSimJob:simJob];
    }
}
@end
