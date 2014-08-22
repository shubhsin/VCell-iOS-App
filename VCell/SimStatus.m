//
//  SimStatus.m
//  VCell
//
//  Created by Ankit Aggarwal on 22/08/14.
//  Copyright (c) 2014 vcell. All rights reserved.
//

#import "SimStatus.h"

@implementation SimStatus


- (instancetype)initWithDict:(NSDictionary*)dict
{
    if(self = [super init]){
        _simRep = [NewApplication initWithDict:[dict objectForKey:@"simRep"]];
        _statusString = [dict objectForKey:@"statusString"];
        _details = [dict objectForKey:@"details"];
        _failedMessage = [dict objectForKey:@"failedMessage"];
        _progress = [dict objectForKey:@"progress"];
        _numberOfJobsDone = [dict objectForKey:@"numberOfJobsDone"];
        _bRunnable = [[dict objectForKey:@"bRunnable"] boolValue];
        _bStoppable = [[dict objectForKey:@"bStoppable"] boolValue];
        _bHasData = [[dict objectForKey:@"bHasData"] boolValue];
        _bStatusActive = [[dict objectForKey:@"bStatusActive"] boolValue];
        _bStatusCompleted = [[dict objectForKey:@"bStatusCompleted"] boolValue];
        _bStatusStopped = [[dict objectForKey:@"bStatusStopped"] boolValue];
        _bStatusFailed = [[dict objectForKey:@"bStatusFailed"] boolValue];
    }
    return self;
}

@end
