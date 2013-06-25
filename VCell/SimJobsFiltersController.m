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
}
@end

@implementation SimJobsFiltersController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    
    //Load the plist file to dict
    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:SIMJOB_FILTERS_FILE];

    URLparams = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
 
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
   
    [keys enumerateObjectsWithOptions:NSEnumerationConcurrent
            usingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {

                UITableViewCell *cell = [cells objectAtIndex:idx];
                NSString *data = [URLparams objectForKey:key];
                NSLog(@"%@",data);
                if(![data isEqualToString:@""])
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",data];
            
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    //UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
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

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



@end
