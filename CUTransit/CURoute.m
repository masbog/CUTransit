//
//  CURoute.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "CURoute.h"

@implementation CURoute

@synthesize routeID, routeLongName, routeShortName, routeColor, routeTextColor, schedule, map;

static UIColor* colorFromString(NSString* s) {
	unsigned rgbValue;
	[[NSScanner scannerWithString:s] scanHexInt:&rgbValue];
	return [UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0
						   green:((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0
							blue:((CGFloat)(rgbValue & 0xFF))/255.0
						   alpha:1.0f];
}

- (id)initWithDictionary:(id)dic {
	if (self = [super init]) {
		self.routeID = [dic objectForKey:@"route_id"];
		self.routeLongName = [dic objectForKey:@"route_long_name"];
		self.routeShortName = [dic objectForKey:@"route_short_name"];
		self.routeColor = colorFromString([dic objectForKey:@"route_color"]);
		self.routeTextColor = colorFromString([dic objectForKey:@"route_text_color"]);
	}
	return self;
}

- (void)dealloc {
	[routeID release];
	[routeLongName release];
	[routeShortName release];
	[routeColor release];
	[routeTextColor release];
	[schedule release];
	[map release];
	[super dealloc];
}

@end
