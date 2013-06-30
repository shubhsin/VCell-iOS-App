//
//  GraphAxisSelectController.m
//  VCell
//
//  Created by Aciid on 30/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "GraphAxisSelectController.h"

@interface GraphAxisSelectController ()
{
    SimGraph *simGraph;
    NSIndexPath *selectedIndexPath;
}
@end

@implementation GraphAxisSelectController

- (void)viewDidLoad
{
    [super viewDidLoad];
    simGraph = [[SimGraph alloc] initWithDict:nil];
    simGraph.XVar = [NSMutableIndexSet indexSet];
    simGraph.YVar = [NSMutableIndexSet indexSet];
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
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.section == VIEWDATA)
    {
        cell.textLabel.text = @"View Graph";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }
    if(selectedIndexPath == indexPath)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.textLabel.text = [simGraph.variables objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showGraph"])
    {
        [[segue destinationViewController] setObject:simGraph];
    }

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if(indexPath.section == VIEWDATA)
    {
        [self performSegueWithIdentifier:@"showGraph" sender:nil];
    }
    
    if (indexPath.section == XAXIS)
    {
        [[self.tableView cellForRowAtIndexPath:selectedIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
        
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
            cell.accessoryType = UITableViewCellAccessoryNone;
        else
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        selectedIndexPath = indexPath;
        
        [simGraph.XVar removeAllIndexes];
        [simGraph.XVar addIndex:indexPath.row];
    }
    
    if(indexPath.section == YAXIS)
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
    [cell setSelected:NO animated:NO];
}

@end
