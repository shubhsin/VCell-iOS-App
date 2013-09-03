//
//  SecondViewController.h
//  VCell
//
//  Created by Aciid on 09/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimGraph.h"

@interface GraphViewController : UIViewController <CPTPlotDataSource, UIAlertViewDelegate, FetchJSONDelegate>

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;

- (void)setGraphObject:(SimGraph *)obj;

@end
