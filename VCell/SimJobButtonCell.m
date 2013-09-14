/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

#import "SimJobButtonCell.h"

@implementation SimJobButtonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnPressed:(id)sender
{
    
    UIButton *button = (UIButton*)sender;
    //Imitate toggle behavior for the buttons.
    BOOL active;
    //toggle the switch
    if(button.selected)
    {
        button.selected = NO;
        active = NO;
    }
    else
    {
        button.selected = YES;
        active = YES;
    }
    
    //Save the state to disk
    NSString *key;
    if(button.tag  == COMPLETED_BTN)
        key = @"completed";
    else if(button.tag == RUNNING_BTN)
        key = @"running";
    else if(button.tag == STOPPED_BTN)
        key = @"stopped";
    
    [[NSUserDefaults standardUserDefaults] setBool:button.selected forKey:key];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.delegate updatDataOnBtnPressedWithButtonTag:button.tag AndButtonActive:active];

}
@end
