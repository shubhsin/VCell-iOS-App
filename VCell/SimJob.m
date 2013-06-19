//
//  SimJob.m
//  VCell
//
//  Created by Aciid on 10/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "SimJob.h"

@implementation SimJob
- (NSString*)startDateString
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self.startdate doubleValue]/1000];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"EEEE',' d MMMM yyyy";
    return [dateFormat stringFromDate:date];
}
- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if(self)
    {
        _simKey = [dict objectForKey:@"simKey"];
        _simName = [dict objectForKey:@"simName"];
        _userName = [dict objectForKey:@"userName"];
        _userKey = [dict objectForKey:@"userKey"];
        _htcJobId = [dict objectForKey:@"htcJobId"];
        _status = [dict objectForKey:@"status"];
        _startdate = [dict objectForKey:@"startdate"];
        _jobIndex = [dict objectForKey:@"jobIndex"];
        _taskId = [dict objectForKey:@"taskId"];
        _message = [dict objectForKey:@"message"];
        _site = [dict objectForKey:@"site"];
        _computeHost = [dict objectForKey:@"computeHost"];
        _schedulerStatus = [dict objectForKey:@"schedulerStatus"];
        _hasData = [dict objectForKey:@"hasData"];

        if([dict objectForKey:@"bioModelLink"] != [NSNull null])
        {
            _bioModelLink = [[BioModelLink alloc] init];
            
            _bioModelLink.bioModelKey = [[dict objectForKey:@"bioModelLink"] objectForKey:@"bioModelKey"];
            _bioModelLink.bioModelBranchId = [[dict objectForKey:@"bioModelLink"] objectForKey:@"bioModelBranchId"];
            _bioModelLink.bioModelName = [[dict objectForKey:@"bioModelLink"] objectForKey:@"bioModelName"];
            _bioModelLink.simContextKey = [[dict objectForKey:@"bioModelLink"] objectForKey:@"simContextKey"];
            _bioModelLink.simContextBranchId = [[dict objectForKey:@"bioModelLink"] objectForKey:@"simContextBranchId"];
            _bioModelLink.simContextName = [[dict objectForKey:@"bioModelLink"] objectForKey:@"simContextName"];
            
        }
        if([dict objectForKey:@"mathModelLink"] != [NSNull null])
        {
            _mathModelLink = [[MathModelLink alloc] init];
            
            _mathModelLink.mathModelKey = [[dict objectForKey:@"mathModelLink"] objectForKey:@"mathModelKey"];
            _mathModelLink.mathModelBranchId = [[dict objectForKey:@"mathModelLink"] objectForKey:@"mathModelBranchId"];
            _mathModelLink.mathModelName = [[dict objectForKey:@"mathModelLink"] objectForKey:@"mathModelName"];
        }
        

    }
    return self;
    
}
- (NSString*)description
{
    return [NSString stringWithFormat:@"%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@",
            _simKey,
            _simName,
            _userName,
            _userKey,
            _htcJobId,
            _status,
            _startdate,
            _jobIndex,
            _taskId,
            _message,
            _site,
            _computeHost,
            _schedulerStatus,
            _hasData,
            _bioModelLink,
            _mathModelLink];
}


@end

@implementation BioModelLink

- (NSString*)description
{
    return [NSString stringWithFormat:@"BioModel:%@;%@;%@;%@;%@;%@",
            _bioModelKey,
            _bioModelBranchId,
            _bioModelName,
            _simContextKey,
            _simContextBranchId,
            _simContextName];
}

@end

@implementation MathModelLink

- (NSString*)description
{
    return [NSString stringWithFormat:@"MathModel:%@;%@;%@",
            _mathModelKey,
            _mathModelBranchId,
            _mathModelName];
}

@end