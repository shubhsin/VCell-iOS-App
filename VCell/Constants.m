//
//  Constants.m
//  VCell
//
//  Created by Aciid on 16/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "Constants.h"

NSString * const SIMJOB_FILTERS_FILE = @"simJobFilters.plist";
NSString * const BIOMODEL_FILTERS_FILE = @"biomodelFilters.plist";

#ifdef LOCALHOST
#define EXTENSION @".php"
#define URL_DEF @"http://192.168.1.2/vcell"
#else
#define EXTENSION @""
//#define URL_DEF @"https://vcellapi.cam.uchc.edu:8080"
#define URL_DEF @"https://vcell-prod.apigee.net/v1/vcellapi"
#endif

NSString * const BASE_URL = URL_DEF;

NSString * const SIMTASK_URL = URL_DEF "/simtask" EXTENSION;

NSString * const BIOMODEL_URL = URL_DEF "/biomodel" EXTENSION;

NSString * const ACCESS_TOKEN_URL = URL_DEF "/access_token" EXTENSION;

NSString * const CLIENT_ID = @"Tl3zecmvYDcA1c8dtTrxL8ae0cPukFpo";

