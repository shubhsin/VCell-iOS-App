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

@interface ParameterSelectTableViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (assign, nonatomic) BOOL parametersSelected;
@property AddParamView *paramView;

@end

@implementation ParameterSelectTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.parametersSelected = YES;
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
        cell.addedState = [self.application parameterinOverrides:param];
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
    ParameterSelectTableViewCell *cell = (ParameterSelectTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if(cell.addedState)
        return;
    
    if(!self.paramView) {
        self.paramView = [[[NSBundle mainBundle] loadNibNamed:@"AddParamView" owner:self options:nil] objectAtIndex:0];
    }
    self.paramView.parameterSelectTableViewController = self;

    ApplicationParameters *param = self.application.parameters[indexPath.row];

    
    NSDictionary *dict = @{@"name" : param.name , @"values" : @[param.defaultValue] , @"type" : @"Single"};
    
    self.paramView.override = [[ApplicationOverride alloc] initWithDict:dict];
    
    UIImageView *blurView = [[UIImageView alloc] initWithFrame:self.navigationController.view.frame];
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

-(UIImage *)blurredSnapshotforView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, view.window.screen.scale);
    [view drawViewHierarchyInRect:view.frame afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIColor *tintColor = [UIColor colorWithWhite:0.2 alpha:0.73];
    UIImage *blurredSnapshotImage = [snapshotImage applyBlurWithRadius:8 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
    UIGraphicsEndImageContext();
    return blurredSnapshotImage;
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
