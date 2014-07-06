//
//  ResourceViewController.h
//  VCell_14
//
//  Created by Ankit Agarwal on 11/06/14.
//  Copyright (c) 2014 ankit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResourceViewController : UIViewController <UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableViewRunning;
@property (nonatomic, weak) IBOutlet UITableView *tableViewQueue;

@end
