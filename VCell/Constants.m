//
//  Constants.m
//  VCell
//
//  Created by Aciid on 16/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "Constants.h"

NSString * const SIMJOB_FILTERS_FILE = @"simJobFilters.plist";

#ifdef LOCALHOST
#define EXTENSION @".php"
#define URL_DEF @"http://localhost/vcell"
#else
#define EXTENSION @""
#define URL_DEF @"https://vcellapi.cam.uchc.edu:8080"
#endif

NSString * const BASE_URL = URL_DEF;

NSString * const SIMTASK_URL = URL_DEF "/simtask" EXTENSION;

NSString * const BIOMODEL_URL = URL_DEF "/biomodel" EXTENSION;



