//
//  CURoute.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CURoute : NSObject {
	NSString *routeID;
	NSString *routeLongName;
	NSString *routeShortName;
	UIColor *routeColor;
	UIColor *routeTextColor;
	
	// internal use
	NSString *schedule;
	NSString *map;
}

- (id)initWithDictionary:(id)dic;

@property (nonatomic, retain) NSString *routeID;
@property (nonatomic, retain) NSString *routeLongName;
@property (nonatomic, retain) NSString *routeShortName;
@property (nonatomic, retain) UIColor *routeColor;
@property (nonatomic, retain) UIColor *routeTextColor;

@property (nonatomic, retain) NSString *schedule;
@property (nonatomic, retain) NSString *map;

@end
