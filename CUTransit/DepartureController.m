//
//  DepartureController.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "DepartureController.h"
#import "common.h"
#import "ShapeView.h"
#import "TitleView.h"
#import "DepartureAnnotationView.h"

@implementation DepartureController

@synthesize departure, mapView, stop, looksAhead;

- (id)initWithDeparture:(CUDeparture*)d stop:(CUStop*)s {
	if (self = [super init]) {
		self.departure = d;
		self.stop = s;
		
		[self setupTitleView];
		[self setupRefreshButton];
		titleView.text = departure.headsign;
		
		[self resetTimer];
	}
	return self;
}

- (void)setupTitleView {
	titleView = [[TitleView alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
	[titleView setUpdated];
	self.navigationItem.titleView = titleView;
	[titleView release];
}

- (void)setupRefreshButton {
	refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																  target:self action:@selector(refreshAction:)];
	refreshButton.style = UIBarButtonItemStyleBordered;
	self.navigationItem.rightBarButtonItem = refreshButton;
	[refreshButton release];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:mapView];
	[mapView release];
	
	mapView.showsUserLocation = YES;
	mapView.delegate = self;
	[mapView addAnnotation:stop];
	[mapView addAnnotation:departure];
	
	if (departure.coordinate.latitude != 0.0 || departure.coordinate.latitude != 0.0) {
		// TODO: should be smarter than this
		MKCoordinateRegion region;
		region.center = stop.coordinate;
		region.span.latitudeDelta = MAX(0.01, fabs(stop.coordinate.latitude - departure.coordinate.latitude)*2.2);
		region.span.longitudeDelta = MAX(0.01, fabs(stop.coordinate.longitude - departure.coordinate.longitude)*2.2);
		[mapView setRegion:region animated:YES];
	} else {
		alert(@"Could not determine the location of the bus", @"The bus is not monitored.");
		MKCoordinateRegion region;
		region.center = stop.coordinate;
		region.span.latitudeDelta = 0.004*2;
		region.span.longitudeDelta = 0.004*2;
		[mapView setRegion:region animated:YES];
	}
	
	if ([departure.trip.shapeID isKindOfClass:[NSString class]]) { // could be NSNull
		CUConnection *con = [CUConnection sharedConnection];
		[con requestShapeByShapeID:departure.trip.shapeID handler:
		 ^(id data, CUError *error) {
			 if (data) {
				 CUShape *shape = data;
				 dispatch_async(dispatch_get_main_queue(), ^{
					 [mapView addOverlay:shape];
				 });
			 } else {
				 dispatch_async(dispatch_get_main_queue(), ^{
					 handleCommonError(error);
				 });
			 }
		 }
		 ];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	if (self.parentViewController == nil) { // the view controller has been popped from the stack
		[timer invalidate];
		timer = nil;
	}
}

- (void)resetTimer {
	[timer invalidate];
	timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(scheduledRefresh:) userInfo:nil repeats:YES];
}

#pragma mark - Actions

- (void)refresh {
	if (![departure.vehicleID isKindOfClass:[NSString class]]) { // could be NSNull
		alert(@"Error", @"Could not determine the location of the bus.");
		return;
	}
	
	titleView.text2 = @"Loading...";
	refreshButton.enabled = NO;
	
	CUConnection *con = [CUConnection sharedConnection];
	[con requestDeparturesByStopID:stop.stopID lookAhead:looksAhead handler:
	 ^(id data, CUError *error) {
		 if (data) {
			 dispatch_async(dispatch_get_main_queue(), ^{
				 NSArray *departures = data;
				 
				 for (CUDeparture *dep in departures) {
					 if ([dep.vehicleID isKindOfClass:[NSString class]] &&
						 [dep.vehicleID isEqualToString:departure.vehicleID]) {
						 [mapView removeAnnotation:departure];
						 [mapView addAnnotation:dep];
						 self.departure = dep;
						 break;
					 }
				 }
				 
				 [titleView setUpdated];
				 refreshButton.enabled = YES;
			 });
		 } else {
			 dispatch_async(dispatch_get_main_queue(), ^{
				 handleCommonError(error);
			 });
		 }
	 }
	 ];
}

- (void)refreshAction:(id)sender {
	[self refresh];
	[self resetTimer];
}

- (void)scheduledRefresh:(id)userInfo {
	[self refresh];
}

#pragma mark - MapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id < MKAnnotation >)annotation {
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	
	// Bus
	if ([annotation isKindOfClass:[CUDeparture class]]) {
		static NSString* annotationIdentifier = @"annotationIdentifier2";
		DepartureAnnotationView* pinView = (DepartureAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
		if (!pinView) {
			pinView = [[[DepartureAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
			pinView.canShowCallout = YES;
		} else {
			pinView.annotation = annotation;
		}
		return pinView;
	}
	
	// Stop
	static NSString* annotationIdentifier = @"annotationIdentifier";
	MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
	if (!pinView) {
		pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
		pinView.pinColor = MKPinAnnotationColorRed;
		pinView.canShowCallout = YES;
	} else {
		pinView.annotation = annotation;
	}
	return pinView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	ShapeView *view = [[ShapeView alloc] initWithOverlay:overlay];
	return [view autorelease];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)dealloc {
	[departure release];
	[mapView release];
	[stop release];
	[super dealloc];
}

@end
