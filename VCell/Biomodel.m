//
//  Biomodel.m
//  VCell
//
//  Created by Aciid on 11/07/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "Biomodel.h"
#import "Application.h"
#define StringFromSel(property) NSStringFromSelector((@selector(property)))

@implementation Biomodel

@dynamic bmKey;
@dynamic name;
@dynamic privacy;
@dynamic groupUsers;
@dynamic savedDate;
@dynamic branchID;
@dynamic modelKey;
@dynamic ownerName;
@dynamic ownerKey;
@dynamic annot;
@dynamic applications;

- (NSString *)savedDateString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = DATEFORMAT;
    return [dateFormat stringFromDate:self.savedDate];
}

+ (id)biomodelWithDict:(NSDictionary*)dict inContext:(NSManagedObjectContext*)context
{
    //Biomodel
    Biomodel *biomodel = [NSEntityDescription insertNewObjectForEntityForName:BIOMODEL_ENTITY inManagedObjectContext:context];
   
    biomodel.name = [dict objectForKey:StringFromSel(name)];
    biomodel.bmKey = [NSNumber numberWithInteger:[[dict objectForKey:StringFromSel(bmKey)] integerValue]];
    biomodel.privacy = [dict objectForKey:StringFromSel(privacy)];
    biomodel.groupUsers = [dict objectForKey:StringFromSel(groupUsers)];
    biomodel.savedDate = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:StringFromSel(savedDate)] doubleValue]/1000];
    if([dict objectForKey:StringFromSel(annot)] == [NSNull null])
        biomodel.annot = @"";
    else
        biomodel.annot = [dict objectForKey:StringFromSel(annot)];
    biomodel.branchID = [NSNumber numberWithInteger:[[dict objectForKey:StringFromSel(branchID)] integerValue]];
    biomodel.modelKey = [NSNumber numberWithInteger:[[dict objectForKey:StringFromSel(branchID)] integerValue]];
    biomodel.ownerName = [dict objectForKey:StringFromSel(ownerName)];
    biomodel.ownerKey = [NSNumber numberWithInteger:[[dict objectForKey:StringFromSel(ownerKey)] integerValue]];
    
    //Applications
    NSArray *applications = [dict objectForKey:@"applications"];
    NSMutableOrderedSet *applicationsSet = [NSMutableOrderedSet orderedSet];
    for(NSDictionary *appDict in applications)
    {
        Application *application = [NSEntityDescription insertNewObjectForEntityForName:APPLICATION_ENTITY inManagedObjectContext:context];
        application.name = [appDict objectForKey:StringFromSel(name)];
        application.branchId = [NSNumber numberWithInteger:[[appDict objectForKey:StringFromSel(branchId)] integerValue]];
        application.key = [NSNumber numberWithInteger:[[appDict objectForKey:StringFromSel(key)] integerValue]];
        application.mathKey = [NSNumber numberWithInteger:[[appDict objectForKey:StringFromSel(mathKey)] integerValue]];
        application.biomodel = biomodel;
        [applicationsSet addObject:application];
    }
    biomodel.applications = applicationsSet;
    
    //Simulations
    NSArray *simulations = [dict objectForKey:@"simulations"];
   
    NSMutableArray *simulationsArray = [NSMutableArray array];
    
    for(NSDictionary *simDict in simulations)
    {
        Simulation *simulation = [NSEntityDescription insertNewObjectForEntityForName:SIMULATION_ENTITY inManagedObjectContext:context];    
        
        simulation.key = [NSNumber numberWithInteger:[[simDict objectForKey:StringFromSel(key)] integerValue]];
        simulation.name = [simDict objectForKey:StringFromSel(name)];
        simulation.branchId = [NSNumber numberWithInteger:[[simDict objectForKey:StringFromSel(branchId)] integerValue]];
        simulation.mathKey = [NSNumber numberWithInteger:[[simDict objectForKey:StringFromSel(mathKey)] integerValue]];
        simulation.solverName = [simDict objectForKey:StringFromSel(solverName)];
        simulation.scanCount = [NSNumber numberWithInteger:[[simDict objectForKey:StringFromSel(scanCount)] integerValue]];
        
        [simulationsArray addObject:simulation];
    }

    for(Application *application in biomodel.applications)
    {
        NSMutableOrderedSet *simulationsSet = [NSMutableOrderedSet orderedSet];
        for(Simulation *simulation in simulationsArray)
        {
            if([simulation.mathKey isEqualToNumber:application.mathKey])
            {
                simulation.application = application;
                [simulationsSet addObject:simulation];
            }
        }
        application.simulations = simulationsSet;
    }

    return biomodel;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"BioModel:%@",self.name];
}

@end
