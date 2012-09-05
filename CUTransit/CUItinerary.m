//
//  CUItinerary.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "CUItinerary.h"
#import "CULeg.h"

@implementation CUItinerary

@synthesize startTime, endTime, travelTime, legs;

- (id)initWithDictionary:(id)dic {
	if (self = [super init]) {
		self.startTime = [dic objectForKey:@"start_time"];
		self.endTime = [dic objectForKey:@"end_time"];
		travelTime = [[dic objectForKey:@"travel_time"] intValue];
		
		NSMutableArray *mutableLegs = [[NSMutableArray alloc] init];
		for (id legDic in [dic objectForKey:@"legs"]) {
			CULeg *leg = [[CULeg alloc] initWithDictionary:legDic];
			[mutableLegs addObject:leg];
			[leg release];
		}
		self.legs = mutableLegs;
		[mutableLegs release];
	}
	return self;
}

- (void)dealloc {
	[startTime release];
	[endTime release];
	[legs release];
	[super dealloc];
}

@end
