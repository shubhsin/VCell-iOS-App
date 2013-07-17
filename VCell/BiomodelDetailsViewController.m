//
//  BiomodelDetailsViewController.m
//  VCell
//
//  Created by Aciid on 17/07/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "BiomodelDetailsViewController.h"

@interface BiomodelDetailsViewController ()
{
    Functions *functions;
    Biomodel *biomodel;
    Simulation *simulation;
    Application *application;
    NSArray *simJobs;
}

@end

@implementation BiomodelDetailsViewController

- (void)setObject:(id)obj
{
    if ([obj isKindOfClass:[Biomodel class]]) 
        biomodel = obj;
    else if([obj isKindOfClass:[Application class]])
        application = obj;
    else if ([obj isKindOfClass:[Simulation class]])
        simulation = obj;    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if(biomodel || application)
        self.title = @"Simulations";
    else if(simulation)
    {
        self.title = @"Simulation Jobs";
        
        NSURL *checkJobsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?simId=%d&hasData=all&waiting=on&queued=on&dispatched=on&running=on&completed=on&failed=on&stopped=on&startRow=1&maxRows=200"
                                                    ,SIMTASK_URL,[simulation.key integerValue]]];
        functions = [[Functions alloc] init];
        [functions fetchJSONFromURL:checkJobsURL WithrowNum:1 AddHUDToView:self.navigationController.view delegate:self];

    }    
}

- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData
{

    NSMutableArray *simMutableJobs = [NSMutableArray array];
    
    // Add the objects in the array
    for(NSDictionary *dict in jsonData)
        [simMutableJobs addObject:[[SimJob alloc] initWithDict:dict]];

    simJobs = simMutableJobs;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(biomodel)
        return [[biomodel applications] count];
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(biomodel)
        return [[[biomodel applications] objectAtIndex:section] name];
    if(application)
        return [application name];
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(biomodel)
        return [[[[biomodel applications] objectAtIndex:section] simulations] count];
    if(application)
        return [[application simulations] count];
    if(simulation)
        return [simJobs count];
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if(biomodel)
        cell.textLabel.text = [[[[[biomodel applications] objectAtIndex:indexPath.section] simulations] objectAtIndex:indexPath.row] name];
    
    if(application)
        cell.textLabel.text = [[[application simulations] objectAtIndex:indexPath.row] name];
    
    if(simulation)
        cell.textLabel.text = [[simJobs objectAtIndex:indexPath.row] simName];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(biomodel || application)
    {
        BiomodelDetailsViewController *biomodelDetailsViewController = [[BiomodelDetailsViewController alloc] initWithStyle:UITableViewStylePlain];
        if(biomodel)
            [biomodelDetailsViewController setObject:[[[[biomodel applications] objectAtIndex:indexPath.section] simulations] objectAtIndex:indexPath.row]];
        
        if(application)
            [biomodelDetailsViewController setObject:[[application simulations] objectAtIndex:indexPath.row]];
        
        [self.navigationController pushViewController:biomodelDetailsViewController animated:YES];
    }
    if(simulation)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        SimJobDetailsController *simJobDetailsController = [storyboard instantiateViewControllerWithIdentifier:@"SimJobDetailsController"];
        [simJobDetailsController setObject:[simJobs objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:simJobDetailsController animated:YES];

    }
}

@end
