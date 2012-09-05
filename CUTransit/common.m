//
//  common.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "common.h"
#import "CUError.h"

void alert(NSString *title, NSString *message) {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

MKMapRect optimalRectForCoordinates(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2) {
	MKMapPoint p1 = MKMapPointForCoordinate(c1);
	MKMapPoint p2 = MKMapPointForCoordinate(c2);
	double minX = MIN(p1.x, p2.x);
	double minY = MIN(p1.y, p2.y);
	double maxX = MAX(p1.x, p2.x);
	double maxY = MAX(p1.y, p2.y);
	return MKMapRectMake(minX, minY, maxX-minX, maxY-minY);
}

MKMapRect mapRectWithEdgePadding(MKMapRect rect, UIEdgeInsets edgePadding, MKMapView *view) {
	// this fixes bug in iOS 5
	double ratio, ratio2;
	{
		CGFloat w = edgePadding.left + edgePadding.right;
		CGFloat W = view.bounds.size.width;
		ratio = rect.size.width / (W - w);
	}
	{
		CGFloat w = edgePadding.top + edgePadding.bottom;
		CGFloat W = view.bounds.size.height;
		ratio2 = rect.size.height / (W - w);
	}
	ratio = MAX(ratio, ratio2);
	
	return MKMapRectMake(rect.origin.x - edgePadding.left*ratio,
						 rect.origin.y - edgePadding.top*ratio,
						 rect.size.width + (edgePadding.left + edgePadding.right)*ratio,
						 rect.size.height + (edgePadding.top + edgePadding.bottom)*ratio
						 );
}

MKCoordinateRegion defaultRegion() {
	MKCoordinateRegion region;
	
	// Illini Union
	region.center.latitude = 40.110252;
	region.center.longitude = -88.227809;
	region.span.latitudeDelta = 0.004;
	region.span.longitudeDelta = 0.004;
	return region;
}

NSError *errorWithDescription(NSInteger code, NSString *description) {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  description, NSLocalizedDescriptionKey,
							  nil];
	NSError *error = [[[NSError alloc] initWithDomain:@"cumtd" code:code userInfo:userInfo] autorelease];
	return error;
}

void handleCommonError(CUError *error) {
	if (error)
		alert(@"Error", error.message);
}

NSString *formattedTime(NSString *fullTime) {
	NSUInteger loc = [fullTime rangeOfString:@"T"].location;
	
	NSString *ret = fullTime;
	if (loc != NSNotFound) {
		NSString *tmp = [fullTime substringFromIndex:loc+1];
		NSArray *comps = [tmp componentsSeparatedByString:@":"];
		if ([comps count] >= 2) {
			int hour = [[comps objectAtIndex:0] intValue];
			BOOL pm = hour >= 12;
			if (hour >= 13)
				hour -= 12;
			else if (hour == 0)
				hour = 12;
			ret = [NSString stringWithFormat:@"%d:%@ %@",
				   hour, [comps objectAtIndex:1], pm ? @"PM" : @"AM"];
		}
	}
	return ret;
}

