/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

#import "AccessToken.h"

@implementation AccessToken

static AccessToken *sharedInstance = nil;

+ (id)sharedInstance
{
    return sharedInstance;
}
+ (void)setSharedInstance:(AccessToken*)sI
{
    sharedInstance = sI;
}

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if(self)
    {
        _token = [dict objectForKey:@"token"];
        _creationDateSeconds = [dict objectForKey:@"creationDateSeconds"];
        _expireDateSeconds = [dict objectForKey:@"expireDateSeconds"];
        _userId = [dict objectForKey:@"userId"];
        _userKey = [dict objectForKey:@"userKey"];
    }
    return self;
}
//+ (NSString*)filePath
//{
//    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString* documentsDirectory = [paths objectAtIndex:0];
//    NSString *filePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"access_token.plist"]];
//    return filePath;
//}
//- (void)saveToDisk
//{
//    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:_token,_creationDateSeconds,_expireDateSeconds,_userId,_userKey, nil] forKeys:[NSArray arrayWithObjects:@"token",@"creationDateSeconds",@"expireDateSeconds",@"userId",@"userKey", nil]];
//    [dict writeToFile:[AccessToken filePath] atomically:YES];
//}

//+ (void)deleteUser
//{
//    
//    NSFileManager *manager = [NSFileManager defaultManager];
//    [manager removeItemAtPath:[AccessToken filePath] error:nil];
//    sharedInstance = nil;
//    
//}
//- (id)initFromDisk
//{
//    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[AccessToken filePath]];
//    if([AccessToken tokenExists])
//        self = [self initWithDict:dict];
//    else
//    {
//        self = [super init];
//        self.userId = @"public";
//    }
//    return self;
//}
//+ (BOOL)tokenExists
//{
//    NSFileManager *manager = [NSFileManager defaultManager];
//    if([manager fileExistsAtPath:[AccessToken filePath]])
//        return YES;
//    return NO;
//}



@end
