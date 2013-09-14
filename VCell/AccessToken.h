/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

#import <Foundation/Foundation.h>

@interface AccessToken : NSObject

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSNumber *creationDateSeconds;
@property (nonatomic, strong) NSNumber *expireDateSeconds;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSNumber *userKey;

- (id)initWithDict:(NSDictionary*) dict;
+ (id)sharedInstance;
+ (void)setSharedInstance:(AccessToken*)sI;
//+ (void)deleteUser;
//+ (BOOL)tokenExists;
@end
