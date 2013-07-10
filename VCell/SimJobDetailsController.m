//
//  SimJobDetailsViewController.m
//  VCell
//
//  Created by Aciid on 26/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

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
    NSLog(@"%@",simJob);
    //for iPad
    [self setUpCells];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //for iPhone
    [self setUpCells];

}

- (void)setUpCells
{
    
    //section 0
//    self.viewData = 
//    self.parentApp =
//    self.parentSim =
    
    //section 1
    self.simKey.detailTextLabel.text = simJob.simKey;
    self.simName.detailTextLabel.text = simJob.simName;
    self.status.detailTextLabel.text = simJob.status;
    self.startDate.detailTextLabel.text = [simJob startDateString];
    self.msg.detailTextLabel.text = simJob.message;
    NSLog(@"%@",simJob.simKey);
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
        return;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Details" message:cell.detailTextLabel.text delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
    return NO;
}


@end
