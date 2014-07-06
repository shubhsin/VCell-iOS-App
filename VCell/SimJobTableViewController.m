//
//  SimJobTableViewController.m
//  VCell_14
//
//  Created by Aciid on 05/06/14.
//  Copyright (c) 2014 ankit. All rights reserved.
//

#import "SimJobTableViewController.h"
#import "SimJobTableViewCell.h"
#import "SimJob.h"

@interface SimJobTableViewController ()
{
    NSArray *simJobs;
}

@end

@implementation SimJobTableViewController


- (void)setObject:(NSArray *)obj
{
    simJobs = obj;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView reloadData];
}



#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [simJobs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimJobTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];    
    
    SimJob *simJob = [simJobs objectAtIndex:indexPath.row];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(IS_PHONE)
        [self performSegueWithIdentifier:@"showSimJobDetails" sender:nil];
   // else
     //   [self.simJobDetailsController setObject:[[simJobSections objectAtIndex:indexPath.section - 1] objectAtIndex:indexPath.row]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"showSimJobDetails"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [[segue destinationViewController] setObject:[simJobs objectAtIndex:indexPath.row]];
    }
}


@end
