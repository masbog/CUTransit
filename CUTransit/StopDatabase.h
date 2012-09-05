//
//  StopDatabase.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CUConnection.h"

@interface StopDatabase : NSObject

+ (NSArray*)stops;
+ (NSArray*)sortedStops;
+ (NSString*)stopNameForStopID:(NSString*)stopID;
+ (NSArray*)stopsWithQuery:(NSString*)query;

@end
