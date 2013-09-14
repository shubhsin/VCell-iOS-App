/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

#import "SimJobsFiltersDetail.h"

@interface SimJobsFiltersDetail ()
{
    NSDictionary *URLparams;
    NSString *option;
    NSArray *keys;
    UITableViewCell *tableCell;
    NSDateFormatter *dateFormat;
    NSString *plistPath;
}
@end

@implementation SimJobsFiltersDetail

- (void)setOption:(NSString *)op
{
    option = op;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"EEEE',' d MMMM yyyy";
    
    plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:SIMJOB_FILTERS_FILE];
    
    URLparams = [[NSDictionary alloc] initWithContentsOfFile:plistPath];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if([option isEqualToString:MAXROWS] && section == 0) //Special case for MAXROWS to display 10,20,30,40,50
        return 5;
    if([option isEqualToString:HASDATA] && section == 0)
        return 3;
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
    // Configure the cell...
    if (cell == nil) {
        cell = [[SimJobCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.accessoryType = UITableViewCellAccessoryNone;

    
    //For time stamps
    if(([option isEqualToString:BEGIN_STAMP] || [option isEqualToString:END_STAMP]) && indexPath.row == 0)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDate *date;
        NSString *cellText;
        if([[URLparams objectForKey:option] isEqualToString:@""])
        {
            cellText = @"None";
            date = [NSDate date];
        }
        else
        {
            date = [NSDate dateWithTimeIntervalSince1970:[[URLparams objectForKey:option] doubleValue]];
            cellText = [dateFormat stringFromDate:date];
        }
        
        cell.textLabel.text = cellText;
        
        tableCell = cell;
        CGRect screen = [[UIScreen mainScreen] bounds];
        
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,0,0,0)];
        [picker setDatePickerMode:UIDatePickerModeDate];
        [picker addTarget:self action:@selector(pickerValueChanged:)  forControlEvents:UIControlEventValueChanged];
        [picker setDate:date];
        CGFloat y = (screen.size.height - (picker.bounds.size.height + self.navigationController.navigationBar.bounds.size.height));

        if(!IS_PHONE)
            y = y/2;
        
        [picker setFrame:CGRectMake(0, y, 0, 0)];
        [self.view addSubview:picker];

    }
    
    //Max Rows
    if([option isEqualToString:MAXROWS] && indexPath.section == 0)
    {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.text = [NSString stringWithFormat:@"%d",((indexPath.row + 1) * 10)];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if([[URLparams objectForKey:option] integerValue] == ((indexPath.row + 1) * 10))
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    if([option isEqualToString:HASDATA] && indexPath.section == 0)
    {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        if(indexPath.row == 0)
            cell.textLabel.text = @"any";
        else if(indexPath.row == 1)
            cell.textLabel.text = @"yes";
        else if(indexPath.row == 2)
            cell.textLabel.text = @"no";
        
        if([[URLparams objectForKey:option] isEqualToString:cell.textLabel.text])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;

    }
    
    if(([option isEqualToString:SIMID] || [option isEqualToString:SERVERID] || [option isEqualToString:COMPUTEHOST]) && indexPath.section == 0)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        CGRect frame = CGRectMake(10.0, 0.0, 300.0, 45.0);
        
        UITextField *textField = [[UITextField alloc] initWithFrame:frame];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.textColor = [UIColor blackColor];
        textField.textAlignment = NSTextAlignmentCenter;
        if([[URLparams objectForKey:option] isEqualToString:@""])
            textField.placeholder = @"Enter Text";
        else
            textField.text = [URLparams objectForKey:option];
        textField.backgroundColor = [UIColor whiteColor];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;  // no auto correction support
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyDone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.delegate = self;
        [cell addSubview:textField];
    }
    
    //Clear Button
    if(indexPath.section == 1 && indexPath.row == 0)
    {
        cell.textLabel.text = @"Clear";
        cell.selectionStyle = UITableViewCellSelectionStyleGray;

    }
    
    return cell;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [URLparams setValue:textField.text forKey:option];
    
    [URLparams writeToFile:plistPath atomically:YES];
 
    [self.tableView reloadData];

    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
{
    NSString *footer;

    if(section != 0)
        return footer;
    
    footer = [URLparams objectForKey:option];

    if([option isEqualToString:BEGIN_STAMP] || [option isEqualToString:END_STAMP])
    {    
        if([footer isEqualToString:@""])
            footer = [NSString stringWithFormat:@"Set the Start Date\n Current Value: None"];
        else
            footer = [NSString stringWithFormat:@"Set the Start Date\n Current Value: \n%@",
                        [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:[footer doubleValue]]]];
    }
    
    if([option isEqualToString:MAXROWS])
        footer = [NSString stringWithFormat:@"Set the Number of rows to be fetched at a time.\n Current Value: %@",footer];
    
    if([option isEqualToString:HASDATA])
        footer = [NSString stringWithFormat:@"Should SimJobs have data?\n Current Value: %@",footer];
    
    if([option isEqualToString:SIMID])
       footer = [NSString stringWithFormat:@"Set the SimKey.\n Current Value: %@",footer];

    if([option isEqualToString:SERVERID])
       footer = [NSString stringWithFormat:@"Set the Server ID.\n Current Value: %@",footer];

    if([option isEqualToString:COMPUTEHOST])
        footer = [NSString stringWithFormat:@"Set the Compute Host.\n Current Value: %@",footer];
    
    return footer;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([option isEqualToString:MAXROWS]) //Max Rows Selection
    {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        [URLparams setValue:[NSString stringWithFormat:@"%d",((indexPath.row + 1) * 10)] forKey:option];
        
        [URLparams writeToFile:plistPath atomically:YES];
                
        [self.tableView reloadData];
    }
    
    if([option isEqualToString:HASDATA]) //Has Data Selection
    {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        [URLparams setValue:[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text] forKey:option];
        
        [URLparams writeToFile:plistPath atomically:YES];
        
        [self.tableView reloadData];
    }
    
    if(indexPath.section == 1 && indexPath.row == 0) //Clear button
    {
        //Clear the params
        [URLparams setValue:@"" forKey:option];
        
        //Special cases for HASDATA and MAXROWS
        if([option isEqualToString: HASDATA])
            [URLparams setValue:@"any" forKey:HASDATA];
        if([option isEqualToString: MAXROWS])
            [URLparams setValue:@"10" forKey:MAXROWS];
        
        [URLparams writeToFile:plistPath atomically:YES];
        
        [self.tableView reloadData];
    }
}


- (void)pickerValueChanged:(UIDatePicker *)picker
{
    tableCell.textLabel.text = [dateFormat stringFromDate:[picker date]];
    NSLog(@"%@",[NSString stringWithFormat:@"%.0f",[[picker date] timeIntervalSince1970]]);
    [URLparams setValue:[NSString stringWithFormat:@"%.0f",[[picker date] timeIntervalSince1970]] forKey:option];
    [URLparams writeToFile:plistPath atomically:YES];
    [self.tableView reloadData];
}
@end
