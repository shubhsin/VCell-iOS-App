//
//  Functions.h
//  VCell
//
//  Created by Aciid on 12/07/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Functions : NSObject

//Construct a URL appending '&' on dict keys and objects
+ (NSString*)contructUrlParamsOnDict:(NSDictionary*)dict;

//Returns URL Parameter Dict from disk or save it to disk if it doesnt already
+ (NSMutableDictionary*)initURLParamDictWithFileName:(NSString*)fileName Keys:(NSArray*)keys AndObjects:(NSArray*)objects;
@end
