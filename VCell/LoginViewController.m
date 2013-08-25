//
//  LoginViewController.m
//  VCell
//
//  Created by Aciid on 16/08/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "LoginViewController.h"
#import <CommonCrypto/CommonDigest.h>

@interface LoginViewController ()
{
    AccessToken *accessToken;
}
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:USERPASSKEY])
        [self performSegueWithIdentifier:@"loggedIn" sender:nil];
}

- (NSString*)sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return [output uppercaseString];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1 && indexPath.row == 0) //Login btn
    {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?user_id=%@&user_password=%@",ACCESS_TOKEN_URL,self.usernameTextField.text,[self sha1:self.passwordTextField.text]]];
        NSLog(@"%@",url);
        [[[Functions alloc] init] fetchJSONFromURL:url HUDTextMode:NO AddHUDToView:self.view delegate:self disableTokenMode:YES];
    }
    if(indexPath.section == 1 && indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"loggedIn" sender:nil];
    }
}

- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData function:(Functions *)function
{
    if(jsonData == nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong User/Pass" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
   
        [AccessToken setSharedInstance:[[AccessToken alloc] initWithDict:(NSDictionary*)jsonData]];
        
        NSLog(@"Got token: %@",[[AccessToken sharedInstance] token]);
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSArray arrayWithObjects:self.usernameTextField.text,[self sha1:self.passwordTextField.text], nil] forKey:USERPASSKEY];
        [userDefaults synchronize];
        
        [self performSegueWithIdentifier:@"loggedIn" sender:nil];
    }
}

@end
