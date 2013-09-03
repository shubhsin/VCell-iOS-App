//
//  SimGraph.m
//  VCell
//
//  Created by Aciid on 30/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "SimGraph.h"

@implementation SimGraph

- (id)initWithSimJob:(SimJob*)simjob
{
    self = [super init];
    if(self)
    {
        self.simJob = simjob;
        self.XVar = [NSMutableIndexSet indexSet];
        self.YVar = [NSMutableIndexSet indexSet];
    }
    return self;
}

- (void)setVariables:(NSArray *)vars
{    
    NSMutableArray *array = [NSMutableArray array];
    
    [vars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
 
        if([obj isKindOfClass:[NSDictionary class]])
            [array addObject:[obj objectForKey:@"name"]];
    }];
    _variables = array;
}

- (void)setValues:(NSDictionary *)data
{
    NSArray *array = [data objectForKey:@"variables"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *objDict = obj;
        [dict setObject:[objDict objectForKey:@"values"] forKey:[objDict objectForKey:@"name"]];
    }];
    
    _values = dict;
}

@end
