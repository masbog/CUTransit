//
//  RouteDatabase.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "RouteDatabase.h"

@implementation RouteDatabase

static NSInteger routeSort(id num1, id num2, void *context) {
	int v1 = [((CURoute*)num1).routeShortName intValue];
	int v2 = [((CURoute*)num2).routeShortName intValue];
	if (v1 < v2)
		return NSOrderedAscending;
	else if (v1 > v2)
		return NSOrderedDescending;
	return [((CURoute*)num1).routeLongName compare:((CURoute*)num2).routeLongName];
}

static UIColor* colorFromString(NSString* s) {
	unsigned rgbValue;
	[[NSScanner scannerWithString:s] scanHexInt:&rgbValue];
	return [UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0
						   green:((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0
							blue:((CGFloat)(rgbValue & 0xFF))/255.0
						   alpha:1.0f];
}

+ (NSArray*)routeGroups {
	NSMutableDictionary *colors = [[NSMutableDictionary alloc] init];
	{
		NSString *colorsPath = [[NSBundle mainBundle] pathForResource:@"colors" ofType:@"txt"];
		NSString *colorsStr = [[NSString alloc] initWithContentsOfFile:colorsPath encoding:NSUTF8StringEncoding error:nil];
		for (NSString *line in [colorsStr componentsSeparatedByString:@"\n"]) {
			if ([line length] > 0) {
				NSArray *comps = [line componentsSeparatedByString:@"\t"];
				[colors setObject:colorFromString([comps objectAtIndex:1]) forKey:[comps objectAtIndex:0]];
			}
		}
		[colorsStr release];
	}
	
	NSMutableArray *routeGroups = [NSMutableArray arrayWithCapacity:4];
	for (int i = 0; i < 4; i++) {
		[routeGroups addObject:[NSMutableArray array]];
	}
	static NSString *prefixes[4] = {@"w_", @"e_", @"s_", @"u_"};
	
	NSUInteger i = 0;
	NSString *infoPath = [[NSBundle mainBundle] pathForResource:@"routes" ofType:@"txt"];
	NSString *infoStr = [[NSString alloc] initWithContentsOfFile:infoPath encoding:NSUTF8StringEncoding error:nil];
	for (NSString *line in [infoStr componentsSeparatedByString:@"\n"]) {
		if ([line length] > 0) {
			if ([line isEqualToString:@"-"]) {
				i++;
			} else {
				NSArray *comps = [line componentsSeparatedByString:@"\t"];
				if ([comps count] != 4)
					continue;
				CURoute *route = [[CURoute alloc] init];
				route.routeShortName = [comps objectAtIndex:0];
				route.routeLongName = [comps objectAtIndex:1];
				route.schedule = [prefixes[i] stringByAppendingString:[comps objectAtIndex:2]];
				route.map = [prefixes[i] stringByAppendingString:[comps objectAtIndex:3]];
				route.routeColor = [colors objectForKey:route.routeShortName];
				[[routeGroups objectAtIndex:(i == 0) ? i : i-1] addObject:route];
				[route release];
			}
		}
	}
	[infoStr release];
	
	// sort weekday & evening
	[routeGroups replaceObjectAtIndex:0 withObject:[[routeGroups objectAtIndex:0] sortedArrayUsingFunction:routeSort context:NULL]];
	
	[colors release];
	
	return routeGroups;
}

@end
