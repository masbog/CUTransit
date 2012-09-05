//
//  CULeg.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "CULeg.h"
#import "CUWalk.h"
#import "CUService.h"
#import "CUPoint.h"
#import "CURoute.h"

@implementation CULeg

@synthesize type, walk, services, text, rowHeight;

- (id)initWithDictionary:(id)dic {
	if (self = [super init]) {
		NSString *typeStr = [dic objectForKey:@"type"];
		if ([typeStr isEqualToString:@"Walk"]) {
			type = CULegTypeWalk;
			
			self.walk = [[[CUWalk alloc] initWithDictionary:[dic objectForKey:@"walk"]] autorelease];
		} else if ([typeStr isEqualToString:@"Service"]) {
			type = CULegTypeService;
			
			NSMutableArray *mutableServices = [[NSMutableArray alloc] init];
			for (id serviceDic in [dic objectForKey:@"services"]) {
				CUService *service = [[CUService alloc] initWithDictionary:serviceDic];
				[mutableServices addObject:service];
				[service release];
			}
			self.services = mutableServices;
			[mutableServices release];
		} else {
			type = CULegTypeUnknown;
		}
	}
	return self;
}

- (CLLocationCoordinate2D)beginCoordinate {
	if (type == CULegTypeWalk)
		return walk.begin.coordinate;
	if (type == CULegTypeService) {
		CUService *service = [services objectAtIndex:0];
		return service.begin.coordinate;
	}
	return CLLocationCoordinate2DMake(0, 0);
}

- (CLLocationCoordinate2D)endCoordinate {
	if (type == CULegTypeWalk)
		return walk.end.coordinate;
	if (type == CULegTypeService) {
		CUService *service = [services lastObject];
		return service.end.coordinate;
	}
	return CLLocationCoordinate2DMake(0, 0);
}

- (CLLocationCoordinate2D)coordinate {
	return [self beginCoordinate];
}

- (NSString*)title {
	if (type == CULegTypeWalk)
		return [NSString stringWithFormat:@"Walk to %@", walk.end.name];
	if (type == CULegTypeService) {
		CUService *service = [services objectAtIndex:0];
		return [NSString stringWithFormat:@"Take %@ - %@",
				service.route.routeShortName,
				service.route.routeLongName
				];
	}
	return nil;
}

- (NSString*)subtitle {
	if (type == CULegTypeWalk)
		return [NSString stringWithFormat:@"%.2f miles", walk.distance];
	if (type == CULegTypeService) {
		CUService *service = [services objectAtIndex:0];
		return [NSString stringWithFormat:@"Departed at %@", service.begin.time];
	}
	return nil;
}

- (void)dealloc {
	[walk release];
	[services release];
	[text release];
	[super dealloc];
}

@end
