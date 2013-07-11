//
//  Application.h
//  VCell
//
//  Created by Aciid on 11/07/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Biomodel, Simulation;

@interface Application : NSManagedObject

@property (nonatomic, retain) NSNumber * key;
@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * ownerName;
@property (nonatomic, retain) NSNumber * ownerKey;
@property (nonatomic, retain) NSNumber * mathKey;
@property (nonatomic, retain) NSOrderedSet *simulations;
@property (nonatomic, retain) Biomodel *biomodel;
@end

@interface Application (CoreDataGeneratedAccessors)

- (void)insertObject:(Simulation *)value inSimulationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSimulationsAtIndex:(NSUInteger)idx;
- (void)insertSimulations:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSimulationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSimulationsAtIndex:(NSUInteger)idx withObject:(Simulation *)value;
- (void)replaceSimulationsAtIndexes:(NSIndexSet *)indexes withSimulations:(NSArray *)values;
- (void)addSimulationsObject:(Simulation *)value;
- (void)removeSimulationsObject:(Simulation *)value;
- (void)addSimulations:(NSOrderedSet *)values;
- (void)removeSimulations:(NSOrderedSet *)values;
@end
