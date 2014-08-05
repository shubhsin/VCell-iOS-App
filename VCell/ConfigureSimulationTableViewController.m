//
//  ConfigureSimulationTableViewController.m
//  VCell
//
//  Created by Ankit Agarwal on 31/07/14.
//  Copyright (c) 2014 vcell. All rights reserved.
//

#import "ConfigureSimulationTableViewController.h"
#import "NewApplication.h"
#import "TITokenField.h"

@interface ConfigureSimulationTableViewController () <FetchJSONDelegate>
{
    SimJob *_simJob;
    NewApplication *_application;
    TITokenFieldView *_tokenFieldView;
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
   _application = [NewApplication initWithDict:(NSDictionary*)jsonData];
    
    [self setUpCells];
    [self setupFooterView];
}

- (void)setUpCells
{
    self.nameCell.detailTextLabel.text = _application.name;
    self.modeCell.detailTextLabel.text = _application.bioModelLink.bioModelName;
    self.solverCell.detailTextLabel.text = _application.solverName;
    self.ownerCell.detailTextLabel.text = _application.ownerName;
    self.numJobsCell.detailTextLabel.text = _application.scanCount.stringValue;
    
    //Adjust cell detail text label's width
    NSArray *cells = @[self.nameCell, self.modeCell, self.solverCell, self.ownerCell, self.numJobsCell];

    for(UITableViewCell *cell in cells){
        CGRect frame = [[cell detailTextLabel] frame];
        frame.size.width = self.view.frame.size.width - frame.origin.x - 15;
        [[cell detailTextLabel] setFrame:frame];
    }
}


-(void)setupFooterView {
    
    UILabel *footerHeader = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 0, 0)];
    
    footerHeader.text = @"Overrides";
    footerHeader.textColor = [UIColor grayColor];
    [footerHeader sizeToFit];
    [self.footerView addSubview:footerHeader];
    
    NSMutableArray *overridesArray = [NSMutableArray array];
    
    [_application.overrides enumerateObjectsUsingBlock:^(ApplicationOverride *obj, NSUInteger idx, BOOL *stop) {
        [overridesArray addObject:obj.name];
    }];
    
    _tokenFieldView = [[TITokenFieldView alloc] initWithFrame:CGRectMake(16, 30, 290, 500)];
	[self.footerView addSubview:_tokenFieldView];
    
    [_tokenFieldView.tokenField addTokensWithTitleArray:overridesArray];
    
    _tokenFieldView.tokenField.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    
    [_tokenFieldView.tokenField.tokens enumerateObjectsUsingBlock:^(TIToken *token, NSUInteger idx, BOOL *stop) {
        token.tintColor = [UIColor whiteColor];
        token.representedObject = _application.overrides[idx];
        token.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
    }];
    
    //_tokenFieldView.scrollEnabled = NO;
    _tokenFieldView.tokenField.editable = NO;
    _tokenFieldView.tokenField.backgroundColor = [UIColor whiteColor];
    _tokenFieldView.separator.backgroundColor = [UIColor clearColor];
    
    CGFloat tokenFieldBottom = _tokenFieldView.tokenField.frame.size.height;
    _tokenFieldView.contentSize = CGSizeMake(_tokenFieldView.contentSize.width, tokenFieldBottom);
    
    //Change frame according to content size, contentsize resets after changing frame so twice assignment.
    CGRect frame = _tokenFieldView.frame;
    frame.size.height = _tokenFieldView.contentSize.height;
    _tokenFieldView.frame = frame;
    frame.size.height = _tokenFieldView.contentSize.height;
    _tokenFieldView.frame = frame;
    
    frame = self.footerView.frame;
    frame.size.height = _tokenFieldView.frame.size.height + _tokenFieldView.frame.origin.y;
    self.footerView.frame = frame;
    
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == self.addParametersCell) {
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Details" message:cell.detailTextLabel.text delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.tableView setContentInset:UIEdgeInsetsMake(50, 0, self.footerView.frame.size.height - 50, 0)];
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
