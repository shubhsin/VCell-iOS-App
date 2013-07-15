//
//  Functions.m
//  VCell
//
//  Created by Aciid on 12/07/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "Functions.h"
@interface Functions()
{
    //HUD Variables
    MBProgressHUD *HUD;
    long long expectedLength;
	long long currentLength;
    
    //Class Vars
    NSMutableData *connectionData;
    NSUInteger rowNum;
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

+ (void)deleteAllObjects:(NSString *) entityDescription inManagedObjectContext:(NSManagedObjectContext *) managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *managedObject in items)
    {
        [managedObjectContext deleteObject:managedObject];
        
    }
    
    if (![managedObjectContext save:&error]) {
    	NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
    
//Deletes entire db file.
//    NSError * error;
//    // retrieve the store URL
//    NSURL * storeURL = [[managedObjectContext persistentStoreCoordinator] URLForPersistentStore:[[[managedObjectContext persistentStoreCoordinator] persistentStores] lastObject]];
//    // lock the current context
//    [managedObjectContext lock];
//    [managedObjectContext reset];//to drop pending changes
//    //delete the store from the current managedObjectContext
//    if ([[managedObjectContext persistentStoreCoordinator] removePersistentStore:[[[managedObjectContext persistentStoreCoordinator] persistentStores] lastObject] error:&error])
//    {
//        // remove the file containing the data
//        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
//        //recreate the store like in the  appDelegate method
//        [[managedObjectContext persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
//    }
//    [managedObjectContext unlock];
}

- (void)fetchJSONFromURL:(NSURL*)url WithrowNum:(NSUInteger)rownum AddHUDToView:(UIView*)view delegate:(id)delegate
{
    self.delegate = delegate;
    rowNum = rownum;
    connectionData = [NSMutableData data];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlReq  delegate:self];
    [connection start];
    HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    HUD.delegate = delegate;
    if(rowNum == 1)
    {
        HUD.dimBackground = YES;
        HUD.labelText = @"Fetching...";
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

#pragma mark - NSURLConnectionDelegete

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if(rowNum == 1)
    {
        expectedLength = [response expectedContentLength];
        currentLength = 0;
        HUD.mode = MBProgressHUDModeDeterminate;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(rowNum == 1)
    {
        currentLength += [data length];
        HUD.progress = currentLength / (float)expectedLength;
    }
    [connectionData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Save the received JSON array inside an NSArray
    NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:connectionData options:kNilOptions error:nil];
    if(rowNum == 1)
    {
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.dimBackground = NO;
    }
    [self.delegate fetchJSONDidCompleteWithJSONArray:jsonData];
    HUD.labelText = @"Done!";
    [HUD hide:YES afterDelay:1];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[HUD hide:YES];
}

@end
