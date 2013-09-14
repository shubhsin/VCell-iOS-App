/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

#import "Functions.h"
@interface Functions()
{
    //HUD Variables
    MBProgressHUD *HUD;
    
    //Class Vars
    NSURLConnection *connection;
    NSMutableData *connectionData;
    NSMutableURLRequest *urlReq;
    BOOL HUDTextMode;
    BOOL disableTokenMode;
}
@end

@implementation Functions

+ (NSString*)contructUrlParamsOnDict:(NSDictionary*)dict
{
    NSMutableString *params = [NSMutableString stringWithString:@"?"];
    for(NSString *key in dict)
        [params appendFormat:@"%@=%@&",key,[dict objectForKey:key]];
    return params;
}
+ (NSMutableDictionary*)initURLParamDictWithFileName:(NSString*)fileName Keys:(NSArray*)keys AndObjects:(NSArray*)objects
{
    
    NSMutableDictionary *URLparams;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    if ([fileManager fileExistsAtPath:plistPath] == NO)
    {
        URLparams = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys];
        [URLparams writeToFile:plistPath atomically:YES];
        
    }
    else
        URLparams = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    return URLparams;
}

+ (void)deleteAllObjects:(NSString *) entityDescription inManagedObjectContext:(NSManagedObjectContext *) managedObjectContext withOwner:(NSString *)owner
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    if(owner)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(SELF.bmgroup like '%@')",owner]];
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *managedObject in items)
    {
        [managedObjectContext deleteObject:managedObject];
        
    }
    
    if (![managedObjectContext save:&error]) {
    	NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
}

+ (void)scrollToFirstRowOfNewSectionsWithOldNumberOfSections:(NSIndexPath*)firstCellOfNewData tableView:(UITableView *)tableView
{
    
    //Scroll to newly added section and highlight animate the first row
    
    [UIView animateWithDuration:0.2 animations:^{
        //Scroll to row 0 of the new added section
        [tableView scrollToRowAtIndexPath:firstCellOfNewData atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    } completion:^(BOOL finished){
        //Highlight after scrollToRowAtIndexPath finished
        UITableViewCell *cellToHighlight = [tableView cellForRowAtIndexPath:firstCellOfNewData];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseInOut animations:^
         {
             //Highlight the cell
             [cellToHighlight setHighlighted:YES animated:YES];
         } completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseInOut animations:^
              {
                  //Unhighlight the cell
                  [cellToHighlight setHighlighted:NO animated:YES];
              } completion: NULL];
         }];
    }];
}

+ (NSArray *)makeNSIndexPathsFromArray:(NSArray *)array ForSection:(NSUInteger)section
{
    NSMutableArray *paths = [NSMutableArray array];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [paths addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
        
    }];
    
    return paths;
}

- (void)renewToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?user_id=%@&user_password=%@",ACCESS_TOKEN_URL,[[userDefaults objectForKey:USERPASSKEY] objectAtIndex:0],[[userDefaults objectForKey:USERPASSKEY] objectAtIndex:1]]];
    [[[Functions alloc] init] fetchJSONFromURL:url HUDTextMode:NO AddHUDToView:nil delegate:self disableTokenMode:YES];
}

- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData function:(Functions *)function
{
    if(jsonData == nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong User/Pass" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        [AccessToken setSharedInstance:[[AccessToken alloc] initWithDict:(NSDictionary*)jsonData]];
        [self startConnection];

    }
}

- (void)fetchJSONFromURL:(NSURL*)url HUDTextMode:(BOOL)HUDtextMode AddHUDToView:(UIView*)view delegate:(id)delegate
{
    
    [self fetchJSONFromURL:url HUDTextMode:HUDTextMode AddHUDToView:view delegate:delegate disableTokenMode:[[NSUserDefaults standardUserDefaults] objectForKey:USERPASSKEY]?NO:YES];
}

- (void)fetchJSONFromURL:(NSURL*)url HUDTextMode:(BOOL)HUDtextMode AddHUDToView:(UIView*)view delegate:(id)delegate disableTokenMode:(BOOL)mode
{
    disableTokenMode = mode;
    NSURL *urlWithClientID = [NSURL URLWithString:[NSString stringWithFormat:@"%@&client_id=%@",[url description],CLIENT_ID]];
    self.delegate = delegate;
    HUDTextMode = HUDtextMode;
    connectionData = [NSMutableData data];
    urlReq = [NSMutableURLRequest requestWithURL:urlWithClientID];
    
    [urlReq setHTTPShouldHandleCookies:NO]; // 1.5 days of head banging.
    
    NSLog(@"Performing : %@",urlWithClientID);
    if(view != nil)
    {
        
        HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
        HUD.delegate = delegate;
        [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hudWasCancelled)]];
        if(!HUDTextMode)
        {
            HUD.dimBackground = YES;
            HUD.labelText = @"Tap To Cancel...";
        }
        else
        {
            HUD.mode = MBProgressHUDModeText;
            HUD.labelText = @"Fetching...";
            HUD.margin = 10.f;
            HUD.yOffset = 150.f;
            HUD.userInteractionEnabled = NO;
        }
    }
    
    if(!disableTokenMode)
    {
        NSTimeInterval validity = [[NSDate dateWithTimeIntervalSince1970:[[[AccessToken sharedInstance] expireDateSeconds] doubleValue]] timeIntervalSinceNow];

        if(validity < 0)
        {
            NSLog(@"Renewing token:%@",[[AccessToken sharedInstance] token]);
            [self renewToken];
            return;
        }
    }
    [self startConnection];
}

- (void)startConnection
{
    if(!disableTokenMode)
       [urlReq setValue:[NSString stringWithFormat:@"CUSTOM access_token=%@",[[AccessToken sharedInstance] token]] forHTTPHeaderField:@"Authorization"];
    
    connection = [[NSURLConnection alloc] initWithRequest:urlReq  delegate:self];
    [connection start];
}

#pragma mark - NSURLConnectionDelegete

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [connectionData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Save the received JSON array inside an NSArray
    id jsonData = [NSJSONSerialization JSONObjectWithData:connectionData options:kNilOptions error:nil];
    if(!HUDTextMode)
    {
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.dimBackground = NO;
    }
    if([jsonData isKindOfClass:[NSDictionary class]] && [jsonData objectForKey:@"fault"])
    {
        NSDictionary *error = [jsonData objectForKey:@"fault"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error objectForKey:@"faultstring"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
    else
        [self.delegate fetchJSONDidCompleteWithJSONArray:jsonData function:self];
    if([[HUD gestureRecognizers] objectAtIndex:0])
        [HUD removeGestureRecognizer:[[HUD gestureRecognizers] objectAtIndex:0]]; //Remove the gesture Recognizer which was added to cancel the request in case user taps the HUD after request is complete.
        
    HUD.labelText = @"Done!";
    [HUD hide:YES afterDelay:1];
}

- (void)cancelConnection
{
    [connection cancel];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[HUD hide:YES];
}

- (void)hudWasCancelled
{

    [connection cancel];
    [HUD hide:YES];
}
@end
