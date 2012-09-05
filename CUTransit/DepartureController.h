//
//  DepartureController.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CUConnection.h"

@class TitleView;

@interface DepartureController : UIViewController <MKMapViewDelegate> {
	CUDeparture *departure;
	MKMapView *mapView;
	
	CUStop *stop;
	BOOL looksAhead;
	
	TitleView *titleView;
	UIBarButtonItem *refreshButton;
	NSTimer *timer;
}

- (id)initWithDeparture:(CUDeparture*)d stop:(CUStop*)s;

@property (nonatomic, retain) CUDeparture *departure;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) CUStop *stop;
@property (nonatomic) BOOL looksAhead;

@end
