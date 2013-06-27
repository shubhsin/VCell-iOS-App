//
//  SimJobButtonCell.m
//  VCell
//
//  Created by Aciid on 20/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

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
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        
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
        
        UITabBarController *tabBar = (UITabBarController*)self.window.rootViewController;
        
        for (UIViewController *v in tabBar.viewControllers)
        {
            if ([v isKindOfClass:[UINavigationController class]])
            {
                UINavigationController *nav = (UINavigationController*)v;
                SimJobController *controller = (SimJobController*)[nav visibleViewController];
                [controller updatDataOnBtnPressedWithButtonTag:button.tag AndButtonActive:active];
            }
        }
        
    }];
   

}
@end
