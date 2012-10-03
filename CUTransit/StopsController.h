//
//  FirstViewController.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CUConnection.h"
#import "LocationController.h"

@interface StopsController : UIViewController <LocationControllerDelegate> {
	IBOutlet MKMapView *mapView;
	MKMapView *mapView2;
	
	MKCoordinateRegion region;
	NSArray *searchResults;
	int searchTimestamp;
	id alwaysShownAnnotation;
	BOOL showCallout;
}

- (void)showStop:(CUStop*)stop;

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSArray *searchResults;

@end
