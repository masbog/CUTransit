//
//  CUStop.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "CUStop.h"

@implementation CUStop

@synthesize stopID, stopName, code, coordinate;
@synthesize score;

- (id)initWithDictionary:(id)dic {
	if (self = [super init]) {
		self.stopID = [dic objectForKey:@"stop_id"];
		self.stopName = [dic objectForKey:@"stop_name"];
		self.code = [dic objectForKey:@"code"];
		NSArray *points = [dic objectForKey:@"stop_points"];
		if ([points count] > 0) {
			NSDictionary *point = [points objectAtIndex:0];
			coordinate.latitude = [[point objectForKey:@"stop_lat"] doubleValue];
			coordinate.longitude = [[point objectForKey:@"stop_lon"] doubleValue];
		}
	}
	return self;
}

- (id)dictionary {
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (stopID)
		[dic setObject:stopID forKey:@"stop_id"];
	if (stopName)
		[dic setObject:stopName forKey:@"stop_name"];
	if (code)
		[dic setObject:code forKey:@"code"];
	NSDictionary *point = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithDouble:coordinate.latitude], @"stop_lat",
						   [NSNumber numberWithDouble:coordinate.longitude], @"stop_lon",
						   nil];
	[dic setObject:[NSArray arrayWithObject:point] forKey:@"stop_points"];
	return dic;
}

- (NSString*)title {
	return stopName;
}

- (NSString*)subtitle {
	return code;
}

- (void)dealloc {
	[stopID release];
	[stopName release];
	[code release];
	[super dealloc];
}

@end
