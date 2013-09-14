/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

#import "Constants.h"

NSString * const SIMJOB_FILTERS_FILE = @"simJobFilters.plist";
NSString * const BIOMODEL_FILTERS_FILE = @"biomodelFilters.plist";

#ifdef LOCALHOST
#define EXTENSION @".php"
#define URL_DEF @"http://localhost/vcell"
#else
#define EXTENSION @""
//#define URL_DEF @"https://vcellapi.cam.uchc.edu:8080"
#define URL_DEF @"https://vcell-prod.apigee.net/v1/vcellapi"
#endif

NSString * const BASE_URL = URL_DEF;

NSString * const SIMTASK_URL = URL_DEF "/simtask" EXTENSION;

NSString * const BIOMODEL_URL = URL_DEF "/biomodel" EXTENSION;

NSString * const ACCESS_TOKEN_URL = URL_DEF "/access_token" EXTENSION;

NSString * const SIMDATA_URL = URL_DEF "/simdata" EXTENSION;

NSString * const REGISTER_URL = URL_DEF "/newuser" EXTENSION;

NSString * const CLIENT_ID = @"Tl3zecmvYDcA1c8dtTrxL8ae0cPukFpo";


