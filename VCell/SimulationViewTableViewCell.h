//
//  SimulationViewTableViewCell.h
//  VCell_14
//
//  Created by Aciid on 05/06/14.
//  Copyright (c) 2014 ankit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimulationViewTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *simName;
@property (weak, nonatomic) IBOutlet UILabel *simStatus;
@property (weak, nonatomic) IBOutlet UILabel *numJobs;

@end
