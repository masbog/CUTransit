//
//  CUService.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "CUService.h"
#import "CUPoint.h"
#import "CURoute.h"
#import "CUTrip.h"

@implementation CUService

@synthesize begin, end, route, trip;

- (id)initWithDictionary:(id)dic {
	if (self = [super init]) {
		self.begin = [[[CUPoint alloc] initWithDictionary:[dic objectForKey:@"begin"]] autorelease];
		self.end = [[[CUPoint alloc] initWithDictionary:[dic objectForKey:@"end"]] autorelease];
		self.route = [[[CURoute alloc] initWithDictionary:[dic objectForKey:@"route"]] autorelease];
		self.trip = [[[CUTrip alloc] initWithDictionary:[dic objectForKey:@"trip"]] autorelease];
	}
	return self;
}

- (void)dealloc {
	[begin release];
	[end release];
	[route release];
	[trip release];
	[super dealloc];
}

@end
