//
//  ItineraryController.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CUConnection.h"

@class StepDescriptionView, Location;

@interface ItineraryController : UIViewController <MKMapViewDelegate> {
	CUItinerary *itinerary;
	Location *originLocation;
	Location *destinationLocation;
	
	MKMapView *mapView;
	StepDescriptionView *descriptionView;
	UISegmentedControl *stepControl;
	
	NSArray *steps;
	int stepIndex;
	NSMutableArray *shapes;
	NSMutableArray *highlightedShapes;
	int currentHighlightIndex;
	
	CUPoint *focus;
	CLLocationCoordinate2D newFocusCoordinate;
}

- (id)initWithItinerary:(CUItinerary*)iti originLocation:(Location*)origin destinationLocation:(Location*)dest;

@property (nonatomic, retain) CUItinerary *itinerary;
@property (nonatomic, retain) Location *originLocation;
@property (nonatomic, retain) Location *destinationLocation;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) StepDescriptionView *descriptionView;
@property (nonatomic, retain) UISegmentedControl *stepControl;
@property (nonatomic, retain) NSArray *steps;
@property (nonatomic, retain) NSMutableArray *shapes;
@property (nonatomic, retain) NSMutableArray *highlightedShapes;
@property (nonatomic, retain) CUPoint *focus;

@end
