//
//  RegisterationViewController.h
//  VCell
//
//  Created by Aciid on 07/09/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ERRORDOMAIN @"register"
#define REGISTER_BTN_SECTION 3
#define NOTIFY_BTN_SECTION REGISTER_BTN_SECTION

#define REGISTER_BTN_ROW 1
#define NOTIFY_BTN_ROW 0

@interface RegisterationViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordTF;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTF;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *institutionTF;
@property (weak, nonatomic) IBOutlet UITextField *countryTF;
@property (weak, nonatomic) IBOutlet UITableViewCell *NotifyTF;

@end
