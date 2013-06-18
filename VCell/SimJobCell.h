//
//  SimJobCell.h
//  VCell
//
//  Created by Aciid on 11/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimJobCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *simName;
@property (nonatomic, weak) IBOutlet UILabel *message;
@property (nonatomic, weak) IBOutlet UILabel *htcJobID;
@property (nonatomic, weak) IBOutlet UILabel *status;
@property (nonatomic, weak) IBOutlet UILabel *simKey;
@property (nonatomic, weak) IBOutlet UILabel *startDate;

@end
