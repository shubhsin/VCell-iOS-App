/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

//#define LOCALHOST

#define USERNAME @"schaff"

#define IS_PHONE  UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone
#define DATEFORMAT @"EEEE',' d MMMM yyyy"
#define TICK_MARK @"\342\234\223"
#define SIMJOBTAB 0
#define BIOMODELTAB 1
#define USERPASSKEY @"userpasskey"


extern NSString * const BASE_URL;
extern NSString * const SIMTASK_URL;
extern NSString * const BIOMODEL_URL;
extern NSString * const SIMJOB_FILTERS_FILE;
extern NSString * const BIOMODEL_FILTERS_FILE;
extern NSString * const ACCESS_TOKEN_URL;
extern NSString * const CLIENT_ID;
extern NSString * const SIMDATA_URL;
extern NSString * const REGISTER_URL;