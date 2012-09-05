//
//  CUWalk.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "CUWalk.h"
#import "CUPoint.h"

@implementation CUWalk

@synthesize begin, end, distance;

- (id)initWithDictionary:(id)dic {
	if (self = [super init]) {
		self.begin = [[[CUPoint alloc] initWithDictionary:[dic objectForKey:@"begin"]] autorelease];
		self.end = [[[CUPoint alloc] initWithDictionary:[dic objectForKey:@"end"]] autorelease];
		self.distance = [[dic objectForKey:@"distance"] floatValue];
	}
	return self;
}

- (void)dealloc {
	[begin release];
	[end release];
	[super dealloc];
}

@end
