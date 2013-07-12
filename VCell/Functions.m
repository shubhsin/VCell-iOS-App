//
//  Functions.m
//  VCell
//
//  Created by Aciid on 12/07/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "Functions.h"

@implementation Functions

+ (NSString*)contructUrlParamsOnDict:(NSDictionary*)dict
{
    NSMutableString *params = [NSMutableString stringWithString:@"?"];
    for(NSString *key in dict)
        [params appendFormat:@"%@=%@&",key,[dict objectForKey:key]];
    return params;
}
+ (NSMutableDictionary*)initURLParamDictWithFileName:(NSString*)fileName Keys:(NSArray*)keys AndObjects:(NSArray*)objects
{
    NSMutableDictionary *URLparams;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    if ([fileManager fileExistsAtPath:plistPath] == NO)
    {
        URLparams = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys];
        [URLparams writeToFile:plistPath atomically:YES];
        
    }
    else
        URLparams = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    return URLparams;
}

@end
