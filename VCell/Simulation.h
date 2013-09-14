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
#import <CoreData/CoreData.h>

@class Application;

@interface Simulation : NSManagedObject

@property (nonatomic, retain) NSNumber * key;
@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * ownerName;
@property (nonatomic, retain) NSNumber * ownerKey;
@property (nonatomic, retain) NSNumber * mathKey;
@property (nonatomic, retain) NSString * solverName;
@property (nonatomic, retain) NSNumber * scanCount;
@property (nonatomic, retain) Application *application;

@end
