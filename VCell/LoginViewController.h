//
//  LoginViewController.h
//  VCell
//
//  Created by Aciid on 16/08/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccessToken.h"

@interface LoginViewController : UITableViewController <FetchJSONDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

+ (void)logoutFrom:(UIViewController *)view;

@end
