/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

@class Functions;

@protocol FetchJSONDelegate

- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData function:(Functions *)function;

@end

#import <Foundation/Foundation.h>
#import "BiomodelViewController.h"
#import "MBProgressHUD.h"
#import "AccessToken.h"

@interface Functions : NSObject <MBProgressHUDDelegate,FetchJSONDelegate>

//Construct a URL appending '&' on dict keys and objects
+ (NSString*)contructUrlParamsOnDict:(NSDictionary*)dict;

//Returns URL Parameter Dict from disk or save it to disk if it doesnt already
+ (NSMutableDictionary*)initURLParamDictWithFileName:(NSString*)fileName Keys:(NSArray*)keys AndObjects:(NSArray*)objects;

+ (void)scrollToFirstRowOfNewSectionsWithOldNumberOfSections:(NSIndexPath*)firstCellOfNewData tableView:(UITableView*)tableView;

//Makes IndexPaths from array for a section
+ (NSArray *)makeNSIndexPathsFromArray:(NSArray *)array ForSection:(NSUInteger)section;


@property (weak, nonatomic) id <FetchJSONDelegate> delegate;

//Makes a NSURLConnection request fetches data and shows HUD
- (void)fetchJSONFromURL:(NSURL*)url HUDTextMode:(BOOL)HUDtextMode AddHUDToView:(UIView*)view delegate:(id)delegate;

- (void)fetchJSONFromURL:(NSURL*)url HUDTextMode:(BOOL)HUDtextMode AddHUDToView:(UIView*)view delegate:(id)delegate disableTokenMode:(BOOL)mode;

- (void)cancelConnection;

//Delete all objects from Coredata
+ (void)deleteAllObjects:(NSString *) entityDescription inManagedObjectContext:(NSManagedObjectContext *) context withOwner:(NSString *)owner;

@end
