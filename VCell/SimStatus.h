//
//  SimStatus.h
//  VCell
//
//  Created by Ankit Aggarwal on 22/08/14.
//  Copyright (c) 2014 vcell. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "SimJob.h"
#include "NewApplication.h"

@interface SimStatus : NSObject

@property (nonatomic,strong) NewApplication *simRep;
@property (nonatomic,strong) NSString *statusString;
@property (nonatomic,strong) NSString *details;
@property (nonatomic,strong) NSString *failedMessage;
@property (nonatomic,strong) NSNumber *progress;
@property (nonatomic,strong) NSNumber *numberOfJobsDone;
@property (nonatomic,assign) BOOL bRunnable;
@property (nonatomic,assign) BOOL bStoppable;
@property (nonatomic,assign) BOOL bHasData;
@property (nonatomic,assign) BOOL bStatusActive;
@property (nonatomic,assign) BOOL bStatusCompleted;
@property (nonatomic,assign) BOOL bStatusStopped;
@property (nonatomic,assign) BOOL bStatusFailed;

- (instancetype)initWithDict:(NSDictionary*)dict;

@end
