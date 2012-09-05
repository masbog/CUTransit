//
//  FirstViewController.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "StopsController.h"
#import "common.h"
#import "StopController.h"
#import "ShapeView.h"
#import "TitleView.h"
#import "LocationController.h"
#import "StopInfoController.h"
#import "Location.h"
#import "StopDatabase.h"


@implementation StopsController

@synthesize mapView, searchResults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = @"Stops";

		mapView2 = [[MKMapView alloc] initWithFrame:CGRectZero];
		NSArray *stops = [StopDatabase stops];
		[mapView2 addAnnotations:stops];
		
		region = defaultRegion();
		
		[self updateVisibleAnnotations];
	}
	return self;
}

- (id<MKAnnotation>)annotationInGrid:(MKMapRect)gridMapRect usingAnnotations:(NSSet*)annotations {
	NSSet *visibleAnnotaionsInBucket = [mapView annotationsInMapRect:gridMapRect];
	NSSet *annotationsForGridSet = [annotations objectsPassingTest:^BOOL(id obj, BOOL *stop) {
		BOOL returnValue = [visibleAnnotaionsInBucket containsObject:obj];
		if (returnValue)
			*stop = YES;
		return returnValue;
	}];
	
	if ([annotationsForGridSet count] > 0)
		return [annotationsForGridSet anyObject];
	
	MKMapPoint centerMapPoint = MKMapPointMake(MKMapRectGetMidX(gridMapRect), MKMapRectGetMidY(gridMapRect));
	
	CLLocationDistance minDistance;
	id<MKAnnotation> minAnnotation = nil;
	
	for (id<MKAnnotation> annotation in annotations) {
		MKMapPoint mapPoint = MKMapPointForCoordinate(annotation.coordinate);
		CLLocationDistance distance = MKMetersBetweenMapPoints(mapPoint, centerMapPoint);
		if (distance < minDistance || minAnnotation == nil) {
			minDistance = distance;
			minAnnotation = annotation;
		}
	}
	
	return minAnnotation;
}

- (void)updateVisibleAnnotations {
	// This code is taken and modified from a WWDC session video
	
	NSSet *annotationsSet;
	if (mapView.region.span.longitudeDelta > 0.013085) { // too large
		
		MKMapRect rect = mapView.visibleMapRect;
		rect = MKMapRectInset(rect, -rect.size.width*1.2, -rect.size.height*1.2);
		static float bucketSize = 70.0;
		
		// Determine how wide each bucket will be, as a MKMapRect square
		CLLocationCoordinate2D leftCoordinate = [mapView convertPoint:CGPointZero toCoordinateFromView:self.view];
		CLLocationCoordinate2D rightCoordinate = [mapView convertPoint:CGPointMake(bucketSize, 0) toCoordinateFromView:self.view];
		double gridSize = MKMapPointForCoordinate(rightCoordinate).x - MKMapPointForCoordinate(leftCoordinate).x;
		MKMapRect gridMapRect = MKMapRectMake(0, 0, gridSize, gridSize);
		
		// Condense annotations, with a padding of two squares, around the visible maprect
		double startX = floor(MKMapRectGetMinX(rect) / gridSize) * gridSize;
		double startY = floor(MKMapRectGetMinY(rect) / gridSize) * gridSize;
		double endX = floor(MKMapRectGetMaxX(rect) / gridSize) * gridSize;
		double endY = floor(MKMapRectGetMaxY(rect) / gridSize) * gridSize;
		
		// For each square in our grid, pick one annotation to show
		gridMapRect.origin.y = startY;
		while (MKMapRectGetMinY(gridMapRect) <= endY) {
			gridMapRect.origin.x = startX;
			while (MKMapRectGetMinX(gridMapRect) <= endX) {
				NSSet *allAnnotationsInBucket = [mapView2 annotationsInMapRect:gridMapRect];
				
				if ([allAnnotationsInBucket count] > 0) {
					id<MKAnnotation> annotationForGrid = [self annotationInGrid:gridMapRect usingAnnotations:allAnnotationsInBucket];
					[mapView addAnnotation:annotationForGrid];
					
					// Remove annotations which we've decided to cluster
					NSSet *visibleAnnotationsInBucket = [mapView annotationsInMapRect:gridMapRect];
					for (id<MKAnnotation> annotation in allAnnotationsInBucket) {
						if (annotation == annotationForGrid) // exclude self
							continue;
						if (annotation == alwaysShownAnnotation)
							continue;
						if ([visibleAnnotationsInBucket containsObject:annotation]) {
							[mapView removeAnnotation:annotation];
						}
					}
				}
				gridMapRect.origin.x += gridSize;
			}
			gridMapRect.origin.y += gridSize;
		}
	} else {
		MKMapRect rect = mapView.visibleMapRect;
		rect = MKMapRectInset(rect, -rect.size.width*1.0, -rect.size.height*1.0);
		annotationsSet = [mapView2 annotationsInMapRect:rect];
	
		NSArray *currentAnnotations = [mapView annotations];
		NSSet *currentAnnotationsSet = [NSSet setWithArray:currentAnnotations];
		
		for (id annotation in currentAnnotations) {			
			if ([annotation isKindOfClass:[MKUserLocation class]])
				continue;
			if (annotation == alwaysShownAnnotation)
				continue;
			
			if (![annotationsSet containsObject:annotation]) {
				[mapView removeAnnotation:annotation];
			}
		}
		
		for (id annotation in annotationsSet) {
			if (![currentAnnotationsSet containsObject:annotation]) {
				if (annotation == alwaysShownAnnotation)
					continue;
				[mapView addAnnotation:annotation];
			}
		}
	}
}

#pragma mark - user interface

- (void)addTrackingButton {
	UIBarButtonItem *bi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tracking.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(moveToCurrentLocation:)];
	self.navigationItem.leftBarButtonItem = bi;
	[bi release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	[self addTrackingButton];
	
	[mapView setRegion:region animated:NO];
}

- (void)viewWillUnload {
	[super viewWillUnload];
	region = mapView.region;
}

#pragma mark - Actions

- (void)moveToCurrentLocation:(id)sender {
	if (mapView.userLocation.location) {
		region.center = mapView.userLocation.location.coordinate;
		region.span.latitudeDelta = 0.004;
		region.span.longitudeDelta = 0.004;
		[mapView setRegion:region animated:YES];
	}
}

- (void)showDetails:(id)sender {
	MKPinAnnotationView *pinView = (MKPinAnnotationView*)[[sender superview] superview];
	CUStop *stop = pinView.annotation;
	
	StopInfoController *controller = [[StopInfoController alloc] initWithStop:stop];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

#pragma mark - Other

- (void)showStop:(CUStop*)stop {
	alwaysShownAnnotation = stop;
	
	[mapView removeAnnotation:stop]; // this seems to fix the issue of selectannotation not working
	[mapView addAnnotation:stop];

	[mapView selectAnnotation:alwaysShownAnnotation animated:YES];
	
	showCallout = YES;
	
	// must set active before setting region.
	// otherwise, we can't scroll mapview. don't know why.
	[self.searchDisplayController setActive:NO animated:YES];
	
	region.center = stop.coordinate;
	region.span.latitudeDelta = 0.004;
	region.span.longitudeDelta = 0.004;
	[mapView setRegion:region animated:YES];
}


#pragma mark - MapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id < MKAnnotation >)annotation {
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	
	static NSString* annotationIdentifier = @"annotationIdentifier";
	MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
	if (!pinView) {
		pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
		pinView.canShowCallout = YES;
		
		UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[rightButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
		pinView.rightCalloutAccessoryView = rightButton;
	} else {
		pinView.annotation = annotation;
	}
	
	if (showCallout) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[mapView selectAnnotation:alwaysShownAnnotation animated:YES];
		});
	}
	
	return pinView;
}

- (void)mapView:(MKMapView *)_mapView regionDidChangeAnimated:(BOOL)animated {
	[self updateVisibleAnnotations];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	showCallout = NO;
	
	if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
		MKUserLocation *annotation = view.annotation;
		
		CLGeocoder *geocoder = [[CLGeocoder alloc] init];
		[geocoder reverseGeocodeLocation:((MKUserLocation*)annotation).location completionHandler:^(NSArray *placemarks, NSError *error) {
			if ([placemarks count] > 0) {
				CLPlacemark *placemark = [placemarks objectAtIndex:0];
				((MKUserLocation*)annotation).subtitle = placemark.name;
			}
		}];
		[geocoder release];
	}
}

#pragma mark - SearchDisplay Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	searchTimestamp++;
	if ([searchString length] == 0)
		return YES;
	
	int localSearchTimestamp = searchTimestamp;
	CUConnection *con = [CUConnection sharedConnection];
	[con requestStopsBySearch:searchString handler:
	 ^(id data, CUError *error) {
		 if (!data)
			 return;
		 dispatch_async(dispatch_get_main_queue(), ^{
			 if (localSearchTimestamp != searchTimestamp)
				 return;
			 NSArray *stops = data;
			 self.searchResults = stops;
			 
			 [controller.searchResultsTableView reloadData];
			 [controller.searchResultsTableView setContentOffset:CGPointZero];
		 });
	 }
	 ];
	 
	return NO;
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	}
	
	NSUInteger row = indexPath.row;
	if (row < [searchResults count]) {
		CUStop *stop = [searchResults objectAtIndex:row];
		cell.textLabel.text = stop.stopName;
	}
	
	return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = indexPath.row;
	if (row < [searchResults count]) {
		CUStop *stop = [searchResults objectAtIndex:row];
		[self showStop:stop];		
	}
}

#pragma mark - SearchBar delegate

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
	LocationController *controller = [[LocationController alloc] init];
	controller.delegate = self;
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
	[self presentModalViewController:nav animated:YES];
	[nav release];
	[controller release];
}

#pragma mark - LocationController delegate

- (void)locationController:(LocationController*)controller didSelectLocation:(Location*)location {
	[self dismissModalViewControllerAnimated:YES];
	[self showStop:location.stop];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return YES;
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)dealloc {
	[mapView release];
	[searchResults release];
	[super dealloc];
}

@end
