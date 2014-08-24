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
#import "ParameterSelectTableViewController.h"
#import "SimJobTableViewController.h"
#import "GraphAxisSelectController.h"

#define STARTSIMULATION @"Start Simulation"
#define STOPSIMULATION @"Stop Simulation"

@interface ConfigureSimulationTableViewController () <TITokenFieldDelegate, UIAlertViewDelegate>
{
    SimStatus *_simStatus;
    NewApplication *_application;
    TITokenFieldView *_tokenFieldView;
    TIToken *_selectedToken;
}

@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *modeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *ownerCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *solverCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *numJobsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *addParametersCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *startStopSimulationCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *checkJobsCell;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@end

@implementation ConfigureSimulationTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSimulation];
}

- (void)setObject:(SimStatus *)object
{
    _simStatus = object;

}

- (void)loadSimulation
{
    _application = _simStatus.simRep;
    [self setUpCells];
    [self setupFooterView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tokenFieldView.tokenField removeAllTokens];
    [self setupFooterView];
}

- (void)setUpCells
{
    self.nameCell.detailTextLabel.text = _application.name;
    self.modeCell.detailTextLabel.text = _application.bioModelLink.bioModelName;
    self.solverCell.detailTextLabel.text = _application.solverName;
    self.ownerCell.detailTextLabel.text = _application.ownerName;
    self.numJobsCell.detailTextLabel.text = _application.scanCount.stringValue;
    
    if([_simStatus.statusString isEqualToString:@"stopped"] || [_simStatus.statusString isEqualToString:@"failed"] | [_simStatus.statusString isEqualToString:@"completed"])
        self.startStopSimulationCell.textLabel.text = STARTSIMULATION;
    else
        self.startStopSimulationCell.textLabel.text = STOPSIMULATION;
    
    //Adjust cell detail text label's width
    NSArray *cells = @[self.nameCell, self.modeCell, self.solverCell, self.ownerCell, self.numJobsCell];

    for(UITableViewCell *cell in cells) {
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
    _tokenFieldView.tokenField.delegate = self;
	[self.footerView addSubview:_tokenFieldView];
    
    [_tokenFieldView.tokenField addTokensWithTitleArray:overridesArray];
    
    _tokenFieldView.tokenField.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    
    [_tokenFieldView.tokenField.tokens enumerateObjectsUsingBlock:^(TIToken *token, NSUInteger idx, BOOL *stop) {
        token.tintColor = [UIColor whiteColor];
        token.representedObject = _application.overrides[idx];
        token.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
    }];
    
    _tokenFieldView.scrollEnabled = NO;
    _tokenFieldView.tokenField.editable = NO;
    _tokenFieldView.tokenField.backgroundColor = [UIColor whiteColor];
    _tokenFieldView.separator.backgroundColor = [UIColor clearColor];
    
    [self footerFrameUpdate];
}

- (void)footerFrameUpdate
{
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

- (void)tokenFieldDidSelect:(TIToken *)token
{
    if(token.representedObject) {
        _selectedToken = token;
        ApplicationOverride *override = (ApplicationOverride *)token.representedObject;
        NSString *msg =[NSString stringWithFormat:@"Type: %@\nValues: %@\ncardinality: %@",[override stringFromType],override.values,override.cardinality];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Details" message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Remove",nil];
        alertView.tag = 1;
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 0) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        return;
    }
    if(alertView.tag == 1) {
        if (buttonIndex == 1) {
            [_application.overrides removeObject:_selectedToken.representedObject];
            [UIView animateWithDuration:0.2 animations:^{
                _selectedToken.alpha = 0;
            } completion:^(BOOL finished) {
                [_tokenFieldView.tokenField removeToken:_selectedToken];
                [self footerFrameUpdate];
            }];
            
        }
    }
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == self.addParametersCell) {
        
    } else if(cell == self.checkJobsCell) {
        
        [self performSegueWithIdentifier:@"checkJobs" sender:self];
        
    }
    else if(cell == self.startStopSimulationCell) {
        
        [self startStopSimulation];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Details" message:cell.detailTextLabel.text delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        alertView.tag = 0;
        [alertView show];
        
    }
}

- (void)startStopSimulation
{
    NSURL *url;
    if([self.startStopSimulationCell.textLabel.text isEqualToString:STARTSIMULATION]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/simulation/%@/startSimulation",BIOMODEL_URL,_simStatus.simRep.bioModelLink.bioModelKey,_simStatus.simRep.key]];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/simulation/%@/stopSimulation",BIOMODEL_URL,_simStatus.simRep.bioModelLink.bioModelKey,_simStatus.simRep.key]];
    }
    
    NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:url];
    [urlReq setHTTPMethod:@"POST"];
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = @"Working...";
    HUD.margin = 10.f;
    HUD.yOffset = 150.f;
    HUD.userInteractionEnabled = YES;
    
    [NSURLConnection sendAsynchronousRequest:urlReq queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [HUD hide:YES];
     }];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.tableView setContentInset:UIEdgeInsetsMake(50, 0, self.footerView.frame.size.height - 50, 0)];
}

- (IBAction)sendBtnPressed:(id)sender
{

    NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"%@/biomodel/%@/simulation/%@/save",BASE_URL, _simStatus.simRep.bioModelLink.bioModelKey, _simStatus.simRep.key]];
    NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:url];
    
    [urlReq setHTTPMethod:@"POST"];
    [urlReq setValue:[NSString stringWithFormat:@"CUSTOM access_token=%@",[[AccessToken sharedInstance] token]] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *postBody = @{@"overrides" : [_application overrideDict]};

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postBody options:NSJSONWritingPrettyPrinted error:nil];

    [urlReq setHTTPBody:jsonData];
    [urlReq setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = @"Working...";
    HUD.margin = 10.f;
    HUD.yOffset = 150.f;
    HUD.userInteractionEnabled = NO;
    
    [NSURLConnection sendAsynchronousRequest:urlReq queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
         _application = [NewApplication initWithDict:(NSDictionary*)dict];
         [self setUpCells];
         [self setupFooterView];
         [HUD hide:YES];
     }];
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if([[segue identifier] isEqualToString:@"addParam"]){
         [(ParameterSelectTableViewController*)[segue destinationViewController] setApplication:_application];
     }
     if([[segue identifier] isEqualToString:@"checkJobs"]){
         [(SimJobTableViewController*)[segue destinationViewController] setObject:_simStatus];
     }
 }


@end
