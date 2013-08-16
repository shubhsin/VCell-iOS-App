//
//  LoggedInViewController.h
//  VCell
//
//  Created by Aciid on 16/08/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccessToken.h"

@interface LoggedInViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *usernameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *tokenValidityCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *userKeyCell;

@end
