//
//  ParameterSelectTableViewController.m
//  VCell
//
//  Created by Ankit Aggarwal on 06/08/14.
//  Copyright (c) 2014 vcell. All rights reserved.
//

#import "ParameterSelectTableViewController.h"
#import "ParameterSelectTableViewCell.h"
#import "UIImage+ImageEffects.h"

#define kPARAMETERSEGMENT 0
#define kOVERRIDESSEGMENT 1

@interface ParameterSelectTableViewController () <UIAlertViewDelegate,FetchJSONDelegate>
{
    UIAlertView *_removeOverrideAlertView;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (assign, nonatomic) BOOL parametersSelected;
@property AddParamView *paramView;

@end

@implementation ParameterSelectTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.parametersSelected = YES;
    if(_application.parameters.count != 0)
        return;
    
#warning change this
#ifdef LOCALHOST
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/simulation.php?", BASE_URL]];
#else
    NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"%@/biomodel/%@/simulation/%@?",BASE_URL, _application.bioModelLink.bioModelKey, _application.key]];
#endif
    
    [[[Functions alloc] init] fetchJSONFromURL:url HUDTextMode:NO AddHUDToView:self.navigationController.view delegate:self];
}

- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData function:(Functions *)function
{
    NewApplication *app = [NewApplication initWithDict:(NSDictionary*)jsonData];
    _application.parameters = app.parameters;
    [self.tableView reloadData];
}

- (IBAction)segmentChanged:(id)sender
{
    self.parametersSelected = self.segmentControl.selectedSegmentIndex == 0 ? YES : NO;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.parametersSelected ? self.application.parameters.count : self.application.overrides.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ParameterSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if(self.parametersSelected) {
        ApplicationParameters *param = self.application.parameters[indexPath.row];
        cell.name.text = param.name;
        cell.defaultValueLabel.text = param.defaultValue.stringValue;
        cell.context.text = param.modelSymbolContext;
        cell.unitLabel.text = param.modelSymbolUnit;
        cell.addedState = [self.application isParameterinOverrides:param];
    } else {
        ApplicationOverride *override = self.application.overrides[indexPath.row];
        cell.name.text = override.name;
        cell.defaultValueLabel.text = [override stringFromType];
        NSMutableString *valuesString = [NSMutableString string];
        [override.values enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
            [valuesString appendString:obj.stringValue];
            if(idx == override.values.count - 1)
                return;
            [valuesString appendString:@", "];
        }];
        cell.context.text = valuesString;
        cell.unitLabel.text = [NSString stringWithFormat:@"Cardinality: %@", override.cardinality.stringValue];
        cell.addedState = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(!self.parametersSelected){
        _removeOverrideAlertView = [[UIAlertView alloc] initWithTitle:@"Remove Override" message:@"Do you want to remove this override?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [_removeOverrideAlertView show];
        return;
    }
    
    ParameterSelectTableViewCell *cell = (ParameterSelectTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    self.paramView = [[[NSBundle mainBundle] loadNibNamed:@"AddParamView" owner:self options:nil] objectAtIndex:0];
    self.paramView.parameterSelectTableViewController = self;

    self.paramView.param = self.application.parameters[indexPath.row];
    if(!cell.addedState) {
        self.paramView.override = nil;
    }
    else {
        self.paramView.override = [self.application parameterinOverrides:self.application.parameters[indexPath.row]];
    }
    
    CGRect frame = self.navigationController.view.frame;
    frame.origin.y = 20;
    UIImageView *blurView = [[UIImageView alloc] initWithFrame:frame];
    
    blurView.userInteractionEnabled = YES;
    blurView.image = [UIImage imageNamed:@"blurImg.png"];
    [self.navigationController.view addSubview:blurView];
    
    self.paramView.center = CGPointMake(self.navigationController.view.center.x,self.navigationController.view.center.y - 108);
    self.tableView.scrollEnabled = NO;
    self.tableView.allowsSelection = NO;
    [blurView addSubview:self.paramView];
    blurView.alpha = 0;
    self.paramView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height - self.paramView.frame.origin.y);
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        blurView.alpha = 1;
        self.paramView.transform = CGAffineTransformIdentity;
        
    } completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == _removeOverrideAlertView){
        if(buttonIndex == 1){
            ApplicationOverride *override = self.application.overrides[[[self.tableView indexPathForSelectedRow] row]];
            [self.application.overrides removeObject:override];
            [self.tableView reloadData];
        }
    }
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
