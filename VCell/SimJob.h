//
//  SimJob.h
//  VCell
//
//  Created by Aciid on 10/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BioModelLink,MathModelLink;

@interface SimJob : NSObject

@property (nonatomic,strong) NSString *simKey; 
@property (nonatomic,strong) NSString *simName;
@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *userKey;
@property (nonatomic,strong) NSString *htcJobId;
@property (nonatomic,strong) NSString *status;
@property (nonatomic,strong) NSNumber *startdate;
@property (nonatomic,strong) NSNumber *jobIndex;
@property (nonatomic,strong) NSNumber *taskId;
@property (nonatomic,strong) NSString *message;
@property (nonatomic,strong) NSString *site;
@property (nonatomic,strong) NSString *computeHost;
@property (nonatomic,strong) NSString *schedulerStatus;
@property (nonatomic,strong) NSNumber *hasData;
@property (nonatomic,strong) BioModelLink *bioModelLink;
@property (nonatomic,strong) MathModelLink *mathModelLink;

- (id)initWithDict:(NSDictionary*) dict;
- (NSString*)startDateString;
@end

@interface BioModelLink : NSObject

@property (nonatomic,strong) NSString *bioModelKey;
@property (nonatomic,strong) NSString *bioModelBranchId;
@property (nonatomic,strong) NSString *bioModelName;
@property (nonatomic,strong) NSString *simContextKey;
@property (nonatomic,strong) NSString *simContextBranchId;
@property (nonatomic,strong) NSString *simContextName;

@end

@interface MathModelLink : NSObject

@property (nonatomic,strong) NSString *mathModelKey;
@property (nonatomic,strong) NSString *mathModelBranchId;
@property (nonatomic,strong) NSString *mathModelName;

@end




