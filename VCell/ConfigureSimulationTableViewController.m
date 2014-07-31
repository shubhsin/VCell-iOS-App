//
//  ConfigureSimulationTableViewController.m
//  VCell
//
//  Created by Ankit Agarwal on 31/07/14.
//  Copyright (c) 2014 vcell. All rights reserved.
//

#import "ConfigureSimulationTableViewController.h"

@interface ConfigureSimulationTableViewController () <FetchJSONDelegate>
{
    SimJob *_simJob;
}

@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *modeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *ownerCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *solverCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *numJobsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *addParametersCell;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@end

@implementation ConfigureSimulationTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSimulation];
}

- (void)setObject:(SimJob *)object
{
    _simJob = object;
}

- (void)loadSimulation
{
#warning change this
   // NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/biomodel/%@/simulation/%@",BASE_URL, _simJob.bioModelLink.bioModelKey, _simJob.simKey]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/simulation.php?", BASE_URL]];
    [[[Functions alloc] init] fetchJSONFromURL:url HUDTextMode:NO AddHUDToView:self.navigationController.view delegate:self];
}

- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData function:(Functions *)function
{
    

    [self setUpCells];
}

- (void)setUpCells
{
    
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == self.addParametersCell) {
        
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Details" message:cell.detailTextLabel.text delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
