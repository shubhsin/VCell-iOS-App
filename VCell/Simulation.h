//
//  Simulation.h
//  VCell
//
//  Created by Aciid on 11/07/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

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
