//
//  FirstViewController.h
//  VCell
//
//  Created by Aciid on 09/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimJob.h"
#import "SimJobCell.h"
#import "MBProgressHUD.h"

//Constants for sorts
#define BIOMODEL_SORT 0
#define DATE_SORT 1

//Tags for buttons
#define COMPLETED_BTN 10 // completed
#define RUNNING_BTN 20   // running, dispatched, waiting, queued
#define STOPPED_BTN 30  // stopped, failed

@interface SimJobController : UITableViewController <MBProgressHUDDelegate>

- (IBAction)bioModelDateSwap:(id)sender;
- (IBAction)optionsBtnPressed:(id)sender;

@end
