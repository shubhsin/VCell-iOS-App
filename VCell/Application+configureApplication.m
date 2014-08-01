//
//  Application+configureApplication.m
//  VCell
//
//  Created by Ankit Agarwal on 01/08/14.
//  Copyright (c) 2014 vcell. All rights reserved.
//

#import "Application+configureApplication.h"
#import "SimJob.h"

@implementation Application (configureApplication)

@dynamic bioModelLink;
@dynamic scanCount;
@dynamic solverName;
@dynamic overrides;
@dynamic parameters;

+ (instancetype)initWithDict:(NSDictionary*)dict
{
    Application *application = [[Application alloc] init];
    
   // application.bioModelLink = [[BioModelLink alloc] initWithDict:[dict objectForKey:@"bioModelLink"]];
    application.branchId = [dict objectForKey:@"branchId"];
    application.key = [dict objectForKey:@"key"];
    application.mathKey = [dict objectForKey:@"mathKey"];
    application.name = [dict objectForKey:@"name"];
    application.ownerKey = [dict objectForKey:@"ownerKey"];
    application.ownerName = [dict objectForKey:@"ownerName"];
    application.scanCount = [dict objectForKey:@"scanCount"];
    application.solverName = [dict objectForKey:@"solverName"];
    
    NSMutableArray *overrides = [NSMutableArray array];
    for(id obj in [dict objectForKey:@"overrides"]) {
        [overrides addObject:[[ApplicationParameters alloc] initWithDict:obj]];
    }
    application.overrides = [NSArray arrayWithArray:overrides];
    
    NSMutableArray *parameters = [NSMutableArray array];
    for(id obj in [dict objectForKey:@"parameters"]) {
        [parameters addObject:[[ApplicationOverride alloc] initWithDict:obj]];
    }
    application.parameters = [NSArray arrayWithArray:parameters];
    
    return application;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"app: %@ %@ %@",self.name,self.overrides,self.parameters];
}

@end

@implementation ApplicationParameters

- (instancetype)initWithDict:(NSDictionary*)dict
{
    self = [super init];
    if(self) {
     
        self.defaultValue = [dict objectForKey:@"defaultValue"];
        self.modelSymbolContext = [dict objectForKey:@"modelSymbolContext"];
        self.modelSymbolDesc = [dict objectForKey:@"modelSymbolDesc"];
        self.modelSymbolName = [dict objectForKey:@"modelSymbolName"];
        self.modelSymbolUnit = [dict objectForKey:@"modelSymbolUnit"];
        self.modelSymbolType = [dict objectForKey:@"modelSymbolType"];
        self.name = [dict objectForKey:@"name"];
        
    }
    return self;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"param: %@ %@",self.name,self.defaultValue];
}

@end

@implementation ApplicationOverride

- (instancetype)initWithDict:(NSDictionary*)dict
{
    self = [super init];
    if(self) {
        self.cardinality = [dict objectForKey:@"cardinality"];
        self.name = [dict objectForKey:@"name"];
        self.type = [self typeFromString:[dict objectForKey:@"type"]];
        self.values = [dict objectForKey:@"values"];
    }
    return self;
}

- (OverrideType)typeFromString:(NSString *)string
{
    if([string isEqualToString:@"LogInterval"]) {
        return LogInterval;
    } else if([string isEqualToString:@"List"]) {
        return List;
    } else if([string isEqualToString:@"Single"]) {
        return Single;
    } else if([string isEqualToString:@"LinearInterval"]) {
        return LinearInterval;
    } else if([string isEqualToString:@"Dependent"]) {
        return Dependent;
    }
    return NSNotFound;
}

- (NSString*)stringFromType {
    NSString *type;
    
    if(self.type == LogInterval) {
        type = @"LogInterval";
    } else if(self.type == List) {
        type = @"List";
    } else if(self.type == Single) {
        type = @"Single";
    } else if(self.type == LinearInterval) {
        type = @"LinearInterval";
    } else if(self.type == Dependent) {
        type = @"Dependent";
    }
    
    return type;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"override: %@ %@",self.name,self.values];
}

@end