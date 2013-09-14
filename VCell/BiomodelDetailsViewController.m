/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

#import "BiomodelDetailsViewController.h"

@interface BiomodelDetailsViewController ()
{
    Functions *simJobFunc;
    Functions *bioModelFunc;
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
    else if([obj isKindOfClass:[SimJob class]])
        [self searchInStoreOrGetFromInternet:obj];
    
}

- (void)searchInStoreOrGetFromInternet:(SimJob *)simJob
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:BIOMODEL_ENTITY inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"(SELF.bmKey like '%@')",simJob.bioModelLink.bioModelKey]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:nil];
    
    if([fetchedObject count] == 0)
        [self getFromInternet:simJob];
    else
    {
        Biomodel *aBiomodel = [fetchedObject objectAtIndex:0];
        [self setObject:aBiomodel];
        [self setUpView];
        [self.tableView reloadData];
    }
}

- (void)getFromInternet:(SimJob *)simJob
{
    NSURL *bioModelUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?bmId=%@",BIOMODEL_URL,simJob.bioModelLink.bioModelKey]];
    bioModelFunc = [[Functions alloc] init];
    [bioModelFunc fetchJSONFromURL:bioModelUrl HUDTextMode:YES AddHUDToView:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject] delegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpView];
}

- (void)setUpView
{
    if(biomodel || application)
        self.title = @"Simulations";
    else if(simulation)
    {
        self.title = @"Simulation Jobs";
        
        NSURL *checkJobsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?simId=%d&hasData=all&waiting=on&queued=on&dispatched=on&running=on&completed=on&failed=on&stopped=on&startRow=1&maxRows=200"
                                                    ,SIMTASK_URL,[simulation.key integerValue]]];
        simJobFunc = [[Functions alloc] init];
        [simJobFunc fetchJSONFromURL:checkJobsURL HUDTextMode:YES AddHUDToView:self.navigationController.view delegate:self];
        
    }
}

- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData function:(Functions *)function
{
    if (function == simJobFunc)
    {
        NSMutableArray *simMutableJobs = [NSMutableArray array];
        
        // Add the objects in the array
        for(NSDictionary *dict in jsonData)
            [simMutableJobs addObject:[[SimJob alloc] initWithDict:dict]];
        
        simJobs = simMutableJobs;
    }
    else if (function == bioModelFunc)
    {
        biomodel = [Biomodel biomodelWithDict:[jsonData objectAtIndex:0] inContext:[(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext] biomodelGroup:nil];
        [self setUpView];
    }
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        [simJobDetailsController setFromBiomodelTab:YES];
        [simJobDetailsController setObject:[simJobs objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:simJobDetailsController animated:YES];
    }
}

@end
