//
//  BookmarkDatabase.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "CUConnection.h"

@interface BookmarkDatabase : NSObject

+ (NSMutableArray*)stops;
+ (void)addStop:(CUStop*)stop;
+ (void)removeStop:(CUStop*)stop;
+ (void)reorderStops:(NSArray*)stops;
+ (BOOL)hasStop:(CUStop*)stop;
+ (int)revision;

@end
