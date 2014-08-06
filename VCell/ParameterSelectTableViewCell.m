//
//  ParameterSelectTableViewCell.m
//  VCell
//
//  Created by Ankit Aggarwal on 06/08/14.
//  Copyright (c) 2014 vcell. All rights reserved.
//

#import "ParameterSelectTableViewCell.h"

@implementation ParameterSelectTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.addedState = NO;
}

-(void)setAddedState:(BOOL)addedState
{
    _addedState = addedState;
    if(addedState) {
        [self.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([obj isKindOfClass:[UILabel class]])
                [(UILabel*)obj setTextColor:[UIColor blackColor]];
        }];
    } else {
        [self.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([obj isKindOfClass:[UILabel class]])
                [(UILabel*)obj setTextColor:[UIColor grayColor]];
        }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
