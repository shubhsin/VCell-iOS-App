//
//  SimGraph.h
//  VCell
//
//  Created by Aciid on 30/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimJob.h"

@interface SimGraph : NSObject

@property (strong, nonatomic) SimJob *simJob;
@property (strong, nonatomic) NSArray *variables; //to hold the axis variables
@property (strong, nonatomic) NSMutableDictionary *values; //to hold the data values of axis variables; keys: axis variables
@property (strong, nonatomic) NSMutableIndexSet *XVar; // index set to hold the index of varible selected for X axis
@property (strong, nonatomic) NSMutableIndexSet *YVar; // index set to hold the indexes of varibles selected for Y axis

- (id)initWithDict:(NSDictionary*) dict;

@end
