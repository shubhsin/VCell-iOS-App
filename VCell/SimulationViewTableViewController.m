//
//  SimulationViewTableViewController.m
//  VCell_14
//
//  Created by Aciid on 04/06/14.
//  Copyright (c) 2014 ankit. All rights reserved.
//

#import "SimulationViewTableViewController.h"
#import "SimulationViewTableViewCell.h"
#import "SimViewQuotaTableViewCell.h"
#import "SimJobTableViewController.h"
#import "MNMBottomPullToRefreshManager.h"
#import "SimStatus.h"

@interface SimulationViewTableViewController () <MNMBottomPullToRefreshManagerClient>
{
    Functions *fetchSimJobFunc;
    int rowNum;
    NSMutableArray *_simStatusArr;
    BOOL isLoading;
    MNMBottomPullToRefreshManager *_pullToRefreshManager;
}

@end

@implementation SimulationViewTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    rowNum = 1; //Initalize rowNum to 1 initially
    _simStatusArr = [NSMutableArray array];
    fetchSimJobFunc = [[Functions alloc] init]; //For fetching simJobs
    [self startLoading]; //Start the fetching
    _pullToRefreshManager = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:self.tableView withClient:self];
    _pullToRefreshManager.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)startLoading
{
    isLoading = YES;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?submitLow=&submitHigh=&startRow=%d&maxRows=10&simId=&hasData=all&active=on&completed=on&failed=on&stopped=on",SIMSTATUS_URL,rowNum]];
    
    [fetchSimJobFunc fetchJSONFromURL:url HUDTextMode:(rowNum==1?NO:YES) AddHUDToView:self.navigationController.view delegate:self];
}

- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData function:(Functions *)function
{
    if(function == fetchSimJobFunc) {
       
        for(NSDictionary *dict in jsonData) {
            [_simStatusArr addObject:[[SimStatus alloc] initWithDict:dict]];
        }
        
        [self.tableView reloadData];
        [_pullToRefreshManager tableViewReloadFinished];
        isLoading = NO;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_pullToRefreshManager relocatePullToRefreshView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_pullToRefreshManager tableViewScrolled];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_pullToRefreshManager tableViewReleased];
}

- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager {
    rowNum = rowNum + 10;
    [self startLoading];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_simStatusArr count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
        return 30.0f;
    return 55.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        SimViewQuotaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuotaCell" forIndexPath:indexPath];
        cell.quotaMaxLabel.text = @"1";
        cell.quotaRunningLabel.text = @"11";
        cell.quotaWaitingLabel.text = @"22";
        return cell;
    } else {
       
        SimulationViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        SimStatus *simStatus = [_simStatusArr objectAtIndex:indexPath.row-1];
        
        cell.simName.lineBreakMode = NSLineBreakByWordWrapping;
        cell.simName.numberOfLines = 0;
    
        cell.simName.text = simStatus.simRep.name;
        cell.numJobs.text = [simStatus.simRep.scanCount stringValue];
        cell.simStatus.text = simStatus.statusString;
    
        return cell;
    }
    return nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([[segue identifier] isEqualToString:@"simConfig"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [[segue destinationViewController] setObject:[_simStatusArr objectAtIndex:indexPath.row - 1]];
    }
}


@end
