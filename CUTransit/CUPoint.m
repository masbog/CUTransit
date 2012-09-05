//
//  CUPoint.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "CUPoint.h"
#import "common.h"

@implementation CUPoint

@synthesize coordinate, name, stopID, time;

- (id)initWithDictionary:(id)dic {
	if (self = [super init]) {
		coordinate.latitude = [[dic objectForKey:@"lat"] doubleValue];
		coordinate.longitude = [[dic objectForKey:@"lon"] doubleValue];
		self.name = [dic objectForKey:@"name"];
		self.stopID = [dic objectForKey:@"stop_id"];
		self.time = formattedTime([dic objectForKey:@"time"]);
	}
	return self;
}

- (void)dealloc {
	[name release];
	[stopID release];
	[time release];
	[super dealloc];
}

@end
