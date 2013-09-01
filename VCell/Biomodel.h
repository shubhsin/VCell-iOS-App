//
//  Biomodel.h
//  VCell
//
//  Created by Aciid on 11/07/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Simulation.h"

@class Application;

@interface Biomodel : NSManagedObject

@property (nonatomic, retain) NSNumber * bmKey;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * bmgroup;
@property (nonatomic, retain) NSNumber * privacy;
@property (nonatomic, retain) id groupUsers;
@property (nonatomic, retain) NSDate * savedDate;
@property (nonatomic, retain) NSNumber * branchID;
@property (nonatomic, retain) NSNumber * modelKey;
@property (nonatomic, retain) NSString * ownerName;
@property (nonatomic, retain) NSNumber * ownerKey;
@property (nonatomic, retain) NSString * annot;
@property (nonatomic, retain) NSOrderedSet *applications;

//Sending biomodelGroup as nil doesnt save the biomodel in local store
+ (id)biomodelWithDict:(NSDictionary*)dict inContext:(NSManagedObjectContext*)context biomodelGroup:(NSString*)bmg;
- (NSString *)savedDateString;

@end

@interface Biomodel (CoreDataGeneratedAccessors)

- (void)insertObject:(Application *)value inApplicationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromApplicationsAtIndex:(NSUInteger)idx;
- (void)insertApplications:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeApplicationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInApplicationsAtIndex:(NSUInteger)idx withObject:(Application *)value;
- (void)replaceApplicationsAtIndexes:(NSIndexSet *)indexes withApplications:(NSArray *)values;
- (void)addApplicationsObject:(Application *)value;
- (void)removeApplicationsObject:(Application *)value;
- (void)addApplications:(NSOrderedSet *)values;
- (void)removeApplications:(NSOrderedSet *)values;
@end
