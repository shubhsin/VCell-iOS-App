//
//  BiomodelViewController.m
//  VCell
//
//  Created by Aciid on 11/07/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "BiomodelViewController.h"

@interface BiomodelViewController ()
{
    //HUD Variables
    MBProgressHUD *HUD;
    long long expectedLength;
	long long currentLength;
    
    //Class Vars
    NSUInteger numberOfObjectsReceived;
    NSMutableData *connectionData;
    NSUInteger rowNum; //current start row of the data to request
}
@end

@implementation BiomodelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
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
}

#pragma mark - Fetch JSON

- (void)startLoading
{
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@startRow=%d",BIOMODEL_URL,[self contructUrlParamsOnDict:URLparams],rowNum]];
//    NSLog(@"%@",url);
//    connectionData = [NSMutableData data];
//    NSURLRequest *urlReq = [NSURLRequest requestWithURL:url];
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlReq  delegate:self];
//    [connection start];
//    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//    HUD.delegate = self;
//    if(rowNum == 1)
//    {
//        HUD.dimBackground = YES;
//        HUD.labelText = @"Fetching...";
//    }
//    else
//    {
//        HUD.mode = MBProgressHUDModeText;
//        HUD.labelText = @"Fetching...";
//        HUD.margin = 10.f;
//        HUD.yOffset = 150.f;
//        HUD.userInteractionEnabled = NO;
//    }
}

#pragma mark - NSURLConnectionDelegete

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if(rowNum == 1)
    {
        expectedLength = [response expectedContentLength];
        currentLength = 0;
        HUD.mode = MBProgressHUDModeDeterminate;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(rowNum == 1)
    {
        currentLength += [data length];
        HUD.progress = currentLength / (float)expectedLength;
    }
    [connectionData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // Save the received JSON array inside an NSArray
    NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:connectionData options:kNilOptions error:nil];
    
    // Make an empty array with size equal to number of objects received
    NSMutableArray *simMutableJobs = [NSMutableArray array];
    
    // Add the objects in the array
    //for(NSDictionary *dict in jsonData)
    //    [simMutableJobs addObject:[[SimJob alloc] initWithDict:dict]];
    
  
    
    HUD.labelText = @"Done!";
    [HUD hide:YES afterDelay:1];
    
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[HUD hide:YES];
}

#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
}

@end