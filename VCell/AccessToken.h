//
//  AccessToken.h
//  VCell
//
//  Created by Aciid on 16/08/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

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
