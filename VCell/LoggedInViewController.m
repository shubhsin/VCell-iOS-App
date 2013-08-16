//
//  LoggedInViewController.m
//  VCell
//
//  Created by Aciid on 16/08/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "LoggedInViewController.h"

@interface LoggedInViewController ()
{
    AccessToken *accessToken;
}

@end

@implementation LoggedInViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;  
}

- (void)viewWillAppear:(BOOL)animated
{
    accessToken = [AccessToken sharedInstance];
    
    self.usernameCell.detailTextLabel.text = accessToken.userId;
    
    NSTimeInterval validity = [[NSDate dateWithTimeIntervalSince1970:[accessToken.expireDateSeconds doubleValue]] timeIntervalSinceNow];
    
    self.tokenValidityCell.detailTextLabel.text = [NSString stringWithFormat:@"%d Hours",(int)validity/3600];
    self.userKeyCell.detailTextLabel.text = [NSString stringWithFormat:@"%@",accessToken.userKey];
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1 && indexPath.row == 0) //logout button
    {
        [AccessToken deleteUser];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

@end
