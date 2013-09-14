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
#import "SimJob.h"

@interface SimGraph : NSObject

@property (strong, nonatomic) SimJob *simJob;
@property (strong, nonatomic) NSArray *variables; //to hold the axis variables
@property (strong, nonatomic) NSDictionary *values; //to hold the data values of axis variables; keys: axis variables
@property (strong, nonatomic) NSMutableIndexSet *XVar; // index set to hold the index of varible selected for X axis
@property (strong, nonatomic) NSMutableIndexSet *YVar; // index set to hold the indexes of varibles selected for Y axis

- (id)initWithSimJob:(SimJob*)simjob;
- (void)setVariables:(NSArray *)vars;
- (void)setValues:(NSDictionary *)data;

@end
