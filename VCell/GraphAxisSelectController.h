/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

#import <UIKit/UIKit.h>
#import "SimGraph.h"
#import "GraphViewController.h"

#define XAXIS 0
#define YAXIS 1
#define VIEWDATA 2

@interface GraphAxisSelectController : UITableViewController <FetchJSONDelegate>

- (void)setSimJob:(SimJob *)obj;

@end
