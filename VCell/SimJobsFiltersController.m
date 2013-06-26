//
//  SimJobsFiltersController.m
//  VCell
//
//  Created by Aciid on 25/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "SimJobsFiltersController.h"

@interface SimJobsFiltersController ()
{
    NSMutableDictionary *URLparams;
    NSArray *keys;
    NSMutableArray *cells;
    NSString *plistPath;
}
@end

@implementation SimJobsFiltersController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:SIMJOB_FILTERS_FILE];
    
    keys = [NSArray arrayWithObjects:BEGIN_STAMP,
            END_STAMP,
            MAXROWS,
            SERVERID,
            COMPUTEHOST,
            SIMID,
            HASDATA, nil];
    
    cells = [NSMutableArray array];
    [cells addObject:self.dateBeginCell];
    [cells addObject:self.dateEndCell];
    [cells addObject:self.maxRowsCell];
    [cells addObject:self.serverIDCell];
    [cells addObject:self.computeHostCell];
    [cells addObject:self.simulationIDCell];
    [cells addObject:self.hasDataCell];
    
    [self LoadCellsFromDict];
}

- (void)LoadCellsFromDict
{
    //Load the plist file to dict    
    URLparams = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    [keys enumerateObjectsWithOptions:NSEnumerationConcurrent
            usingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {

                UITableViewCell *cell = [cells objectAtIndex:idx];
                NSString *data = [URLparams objectForKey:key];
                if([data isEqualToString:@""])
                    cell.detailTextLabel.text = @"Select";
                else
                {
                    if([key isEqualToString:BEGIN_STAMP] || [key isEqualToString:END_STAMP])
                    {
                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                        dateFormat.dateFormat = @"EEEE',' d MMMM yyyy";
                        cell.detailTextLabel.text = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:[data doubleValue]]];
                    }
                    else
                        cell.detailTextLabel.text = data;
                }
            
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self LoadCellsFromDict];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section != 3) // for last two rows
        [self performSegueWithIdentifier:@"simJobFilterDetailView" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if([[segue identifier] isEqualToString:@"simJobFilterDetailView"])
   {
       SimJobsFiltersDetail *viewController = [segue destinationViewController];
       
       UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
       
       __block NSUInteger indexOfCellSelected;
       
       [cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           
           UITableViewCell *cell = obj;
           if(cell == selectedCell)
           {
               indexOfCellSelected = idx;
               *stop = YES;
           }
           
       }];
       
       [viewController setOption:[keys objectAtIndex:indexOfCellSelected]];
   }
}

#pragma mark - Actions

- (IBAction)doneBtn:(id)sender
{
    [self.delegate SimJobsFiltersControllerDidFinish:self];
}
- (IBAction)clearBtn:(id)sender
{
    
    for(NSString *key in keys)
    {
        if([key isEqualToString:HASDATA])
            [URLparams setValue:@"any" forKey:HASDATA];
        else if([key isEqualToString:MAXROWS])
            [URLparams setValue:@"10" forKey:MAXROWS];
        else
            [URLparams setValue:@"" forKey:key];
    }

    [URLparams writeToFile:plistPath atomically:YES];
    [self LoadCellsFromDict];
}
@end
