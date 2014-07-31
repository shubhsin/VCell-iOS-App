//
//  SimulationViewTableViewController.h
//  VCell_14
//
//  Created by Aciid on 04/06/14.
//  Copyright (c) 2014 ankit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimJob.h"

@interface SimulationViewTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, FetchJSONDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;


@end
