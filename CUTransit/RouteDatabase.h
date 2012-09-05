//
//  RouteDatabase.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CUConnection.h"

static const NSUInteger kRouteDatabaseWeekday = 0;
static const NSUInteger kRouteDatabaseSaturday = 1;
static const NSUInteger kRouteDatabaseSunday = 2;

@interface RouteDatabase : NSObject

+ (NSArray*)routeGroups;

@end
