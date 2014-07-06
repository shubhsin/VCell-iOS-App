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
    NSMutableArray *simJobs;
}

@end

@implementation SimJobTableViewController


- (void)setObject:(NSArray *)obj
{
    simJobs = [NSMutableArray arrayWithArray:obj];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    
    [cell.simStartBtn addTarget:self action:@selector(startStopBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.simDataBtn addTarget:self action:@selector(dataBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    if([simJob.status isEqualToString:@"running"])
        cell.simStatusLabel.text = [NSString stringWithFormat:@"%.0f%% Completed",[simJob.progressValue floatValue]*100];
    
    [cell.simStatusLabel sizeToFit];
    
    return cell;
}

- (void)dataBtnPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"viewData" sender:sender];
}

- (void)startStopBtnPressed:(UIButton *)sender
{
    SimJobTableViewCell *senderCell = (SimJobTableViewCell*)((UIButton*)sender).superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:senderCell];
    SimJob *simJob = [simJobs objectAtIndex:indexPath.row];
    NSURL *url;
    if([sender.titleLabel.text isEqualToString:@"Start"])
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/simulation/%@/startSimulation",BIOMODEL_URL,simJob.bioModelLink.bioModelKey,simJob.simKey]];
    }
    else
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/simulation/%@/stopSimulation",BIOMODEL_URL,simJob.bioModelLink.bioModelKey,simJob.simKey]];
    }
    
    NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:url];
    [urlReq setHTTPMethod:@"POST"];
    [urlReq setValue:[NSString stringWithFormat:@"CUSTOM access_token=%@",[[AccessToken sharedInstance] token]] forHTTPHeaderField:@"Authorization"];
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = @"Working...";
    HUD.margin = 10.f;
    HUD.yOffset = 150.f;
    HUD.userInteractionEnabled = YES;
    
    [NSURLConnection sendAsynchronousRequest:urlReq queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSDictionary *dict = [[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil] objectAtIndex:0];
         SimJob *newSimJob = [[SimJob alloc] initWithDict:dict];
         [simJobs replaceObjectAtIndex:indexPath.row withObject:newSimJob];
         [self.tableView reloadData];
        [HUD hide:YES];
     }];
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
    if ([[segue identifier] isEqualToString:@"viewData"])
    {
        SimJobTableViewCell *senderCell = (SimJobTableViewCell*)((UIButton*)sender).superview;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:senderCell];
        [[segue destinationViewController] setSimJob:[simJobs objectAtIndex:indexPath.row]];
    }

}


@end
