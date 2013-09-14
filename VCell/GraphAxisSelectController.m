/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

#import "GraphAxisSelectController.h"

@interface GraphAxisSelectController ()
{
    SimGraph *simGraph;
    NSIndexPath *selectedIndexPathForXAxis;
}
@end

@implementation GraphAxisSelectController

- (void)setSimJob:(SimJob *)obj
{
    simGraph = [[SimGraph alloc] initWithSimJob:obj];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/%@?",SIMDATA_URL,simGraph.simJob.simKey]];
    
    [[[Functions alloc] init] fetchJSONFromURL:url HUDTextMode:NO AddHUDToView:self.navigationController.view delegate:self];
}

- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData function:(Functions *)function
{
    simGraph.variables = [(NSDictionary *)jsonData objectForKey:@"variables"];
    if(simGraph.variables.count == 0)
        [[[UIAlertView alloc] initWithTitle:@"Message" message:@"No Data" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    else
    {
        [self.tableView reloadData];
        /*
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[Functions makeNSIndexPathsFromArray:simGraph.variables ForSection:XAXIS] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:[Functions makeNSIndexPathsFromArray:simGraph.variables ForSection:YAXIS] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
         */
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;    
    if(section == XAXIS)
        title = @"Select X Axis (Single Selection)";
    else if(section == YAXIS)
        title = @"Select Y Axis (Multiple Selection)";
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == VIEWDATA) //view data button
        return 1;
    return [simGraph.variables count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.accessoryType = UITableViewCellAccessoryNone;

    if(indexPath.section == VIEWDATA)
    {
        cell.textLabel.text = @"View Graph";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    else
    {      
        if(indexPath.row == [simGraph.XVar firstIndex] && indexPath.section == XAXIS)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if(indexPath.section == YAXIS && [simGraph.YVar containsIndex:indexPath.row])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        cell.textLabel.text = [simGraph.variables objectAtIndex:indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(indexPath.section == VIEWDATA)
    {
        [self performSegueWithIdentifier:@"showGraph" sender:self];
    }
    else if(indexPath.section == XAXIS)
    {
        [[tableView cellForRowAtIndexPath:selectedIndexPathForXAxis] setAccessoryType:UITableViewCellAccessoryNone];
        
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
            cell.accessoryType = UITableViewCellAccessoryNone;
        else
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        selectedIndexPathForXAxis = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];

        [simGraph.XVar removeAllIndexes];
        [simGraph.XVar addIndex:indexPath.row];
    }
    else if(indexPath.section == YAXIS)
    {
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [simGraph.YVar removeIndex:indexPath.row];
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [simGraph.YVar addIndex:indexPath.row];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showGraph"])
    {
        [[segue destinationViewController] setGraphObject:simGraph];
    }
    
}
@end
