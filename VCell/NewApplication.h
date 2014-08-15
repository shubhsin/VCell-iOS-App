//
//  Application+configureApplication.h
//  VCell
//
//  Created by Ankit Agarwal on 01/08/14.
//  Copyright (c) 2014 vcell. All rights reserved.
//
@class ApplicationParameters;
@class ApplicationOverride;

@interface NewApplication : NSObject

@property (nonatomic, strong) NSNumber * key;
@property (nonatomic, strong) NSNumber * branchId;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * ownerName;
@property (nonatomic, strong) NSNumber * ownerKey;
@property (nonatomic, strong) NSNumber * mathKey;
@property (nonatomic, strong) NSString *solverName;
@property (nonatomic, strong) NSNumber *scanCount;
@property (nonatomic, strong) BioModelLink *bioModelLink;
@property (nonatomic, strong) NSMutableArray *overrides;
@property (nonatomic, strong) NSArray *parameters;

- (NSArray *)overrideDict;

+ (instancetype)initWithDict:(NSDictionary*)dict;
- (BOOL)isParameterinOverrides:(ApplicationParameters*)param;
- (ApplicationOverride*)parameterinOverrides:(ApplicationParameters*)param;

@end

@interface ApplicationParameters : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *defaultValue;
@property (nonatomic, strong) NSString *modelSymbolContext;
@property (nonatomic, strong) NSString *modelSymbolType;
@property (nonatomic, strong) NSString *modelSymbolName;
@property (nonatomic, strong) NSString *modelSymbolDesc;
@property (nonatomic, strong) NSString *modelSymbolUnit;

- (instancetype)initWithDict:(NSDictionary*)dict;

@end

typedef enum : NSUInteger {
    LogInterval,
    List,
    Single,
    LinearInterval,
    Dependent
} OverrideType;

@interface ApplicationOverride : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) OverrideType type;
@property (nonatomic, strong) NSArray *values;
@property (nonatomic, strong) NSNumber *cardinality;

- (instancetype)initWithDict:(NSDictionary*)dict;

- (NSString*)stringFromType;

-(NSDictionary *)dictObject;

@end