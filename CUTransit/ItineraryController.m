//
//  ItineraryController.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "ItineraryController.h"
#import "common.h"
#import "ShapeView.h"
#import "PointAnnotationView.h"
#import "StepDescriptionView.h"
#import "Location.h"
#import "LegAnnotationView.h"
#import "StopController.h"

#define ORDER_NEXT 0
#define ORDER_PREV 1


typedef struct StepCoordinates {
	int n;
	CLLocationCoordinate2D c1;
	CLLocationCoordinate2D c2;
} StepCoordinates;

@interface Step : NSObject {
	StepCoordinates coordinates; // coordinates where the map should focus
	int legIndex;
	BOOL isEnd;
	int serviceType; // service type (0 = begin, 1 = end)
	int highlightIndex;
}

@property (nonatomic) StepCoordinates coordinates;
@property (nonatomic) int legIndex;
@property (nonatomic) BOOL isEnd;
@property (nonatomic) int serviceType;
@property (nonatomic) int highlightIndex;

@end

@implementation Step

@synthesize coordinates, legIndex, isEnd, serviceType, highlightIndex;

@end

#pragma mark -

@implementation ItineraryController

@synthesize itinerary, originLocation, destinationLocation, mapView, descriptionView, stepControl, steps, shapes, highlightedShapes, focus;

- (id)initWithItinerary:(CUItinerary*)iti originLocation:(Location*)origin destinationLocation:(Location*)dest {
	if (self = [super init]) {
		self.itinerary = iti;
		self.originLocation = origin;
		self.destinationLocation = dest;
		
		currentHighlightIndex = -1;
		[self createSteps];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self setupUI];
	
	mapView.showsUserLocation = YES;
	mapView.delegate = self;
	[mapView addAnnotation:originLocation];
	[mapView addAnnotation:destinationLocation];
	
	// add focus point
	self.focus = [[CUPoint alloc] init];
	focus.coordinate = ((CULeg*)[itinerary.legs objectAtIndex:stepIndex]).beginCoordinate;
	[mapView addAnnotation:focus];
	[focus release];
	
	// load shapes and add overlays
	self.shapes = [NSMutableArray arrayWithCapacity:[itinerary.legs count]];
	self.highlightedShapes = [NSMutableArray arrayWithCapacity:[itinerary.legs count]];
	for (NSUInteger i=0; i<[itinerary.legs count]; i++) {
		[shapes addObject:[NSMutableArray array]];
		[highlightedShapes addObject:[NSMutableArray array]];
	}
	
	CUConnection *con = [CUConnection sharedConnection];
	for (NSUInteger i=0; i<[itinerary.legs count]; i++) {
		CULeg *leg = [itinerary.legs objectAtIndex:i];
		[mapView addAnnotation:leg];
		
		if (i == stepIndex) {
			focus.coordinate = leg.beginCoordinate;
		}
		if (leg.type == CULegTypeService) {
			for (CUService *service in leg.services) {
				[con requestShapeBetweenStopID:service.begin.stopID
									 andStopID:service.end.stopID
									   shapeID:service.trip.shapeID
									   handler:
				 ^(id data, CUError *error) {
					 if (!data)
						 return;
					 CUShape *shape = data;
					 CUShape *highlightedShape = [[shape copy] autorelease];
					 highlightedShape.highlighted = YES;
					 
					 if (((Step*)[steps objectAtIndex:stepIndex]).highlightIndex != i)
						 highlightedShape.hidden = YES;
					 
					 dispatch_async(dispatch_get_main_queue(), ^{
						 [[shapes objectAtIndex:i] addObject:shape];
						 [[highlightedShapes objectAtIndex:i] addObject:highlightedShape];
						 [mapView insertOverlay:shape atIndex:0]; // to make sure that shape is above highlightedShape
						 [mapView addOverlay:highlightedShape];
					 });
				 }
				 ];
			}
		} else if (leg.type == CULegTypeWalk) {
			CUShape *shape = [[CUShape alloc] initWithCoordinate:leg.walk.begin.coordinate andCoordinate:leg.walk.end.coordinate];
			CUShape *highlightedShape = [[shape copy] autorelease];
			highlightedShape.highlighted = YES;
			[[shapes objectAtIndex:i] addObject:shape];
			[[highlightedShapes objectAtIndex:i] addObject:highlightedShape];
			highlightedShape.highlighted = YES;
			
			if (((Step*)[steps objectAtIndex:stepIndex]).highlightIndex != i)
				highlightedShape.hidden = YES;
			
			[mapView insertOverlay:shape atIndex:0];
			[mapView addOverlay:highlightedShape]; // to make sure that shape is above highlightedShape
			[shape release];
		}
	}
	
	[self updateStepWithAnimationOrder:ORDER_NEXT];
}

- (void)setupUI {
	// Step control
	NSArray *items = [[NSArray alloc] initWithObjects:
					  [UIImage imageNamed:@"left_arrow"], 
					  [UIImage imageNamed:@"right_arrow"], nil];
	self.stepControl = [[UISegmentedControl alloc] initWithItems:items];
	stepControl.segmentedControlStyle = UISegmentedControlStyleBar;
	stepControl.momentary = YES;
	stepControl.frame = CGRectMake(0, 0, 88, 30);
	[stepControl addTarget:self action:@selector(changeStep:) forControlEvents:UIControlEventValueChanged];
	
	UIBarButtonItem *bi = [[UIBarButtonItem alloc] initWithCustomView:stepControl];
	self.navigationItem.rightBarButtonItem = bi;
	[bi release];
	
	[stepControl release];
	[items release];
	
	// Map view
	self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
	mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:mapView];
	[mapView release];
	
	// Description view
	self.descriptionView = [[StepDescriptionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44+22+2)];
	descriptionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	descriptionView.delegate = self;
	[self.view addSubview:descriptionView];
	[descriptionView release];
}

- (void)setOverlayStep:(int)i highlighted:(BOOL)highlighted {
	if (i >= 0 && i < [steps count]) {
		Step *st = [steps objectAtIndex:i];
		int highlightIndex = st.highlightIndex;
		if (highlightIndex == -1)
			return;
		
		for (CUShape *shape in [highlightedShapes objectAtIndex:highlightIndex]) {
			if (shape.hidden == highlighted) {
				shape.hidden = !highlighted;
				[mapView viewForOverlay:shape].hidden = shape.hidden;
			}
		}
	}
}

- (void)highlightStep:(int)i {
	if (currentHighlightIndex != i) {
		[self setOverlayStep:currentHighlightIndex highlighted:NO];
		[self setOverlayStep:i highlighted:YES];
		currentHighlightIndex = i;
	}
}

- (void)updateStepWithAnimationOrder:(int)order {
	NSArray *legs = itinerary.legs;
	Step *step = [steps objectAtIndex:stepIndex];
	CULeg *leg = [legs objectAtIndex:step.legIndex];

	if (step.isEnd) { // End
		if (leg.type == CULegTypeWalk) {
			CUWalk *walk = leg.walk;
			descriptionView.text = [NSString stringWithFormat:@"Arrive at %@", walk.end.name];
			descriptionView.text2 = @"";
			descriptionView.showsStopButton = NO;
		} else if (leg.type == CULegTypeService) {
			CUService *service = [leg.services lastObject];
			descriptionView.text = [NSString stringWithFormat:@"Arrive at %@", service.end.name];
			descriptionView.text2 = @"";
			descriptionView.showsStopButton = NO;
		}
		newFocusCoordinate = leg.endCoordinate;
	} else if (leg.type == CULegTypeWalk) { // Walk
		CUWalk *walk = leg.walk;
		descriptionView.text = [NSString stringWithFormat:@"Walk to %@", walk.end.name];
		descriptionView.text2 = [NSString stringWithFormat:@"%.2f miles", walk.distance];
		descriptionView.showsStopButton = NO;
		newFocusCoordinate = walk.begin.coordinate;
	} else if (leg.type == CULegTypeService) { // Service
		if (step.serviceType == 0) {
			CUService *service = [leg.services objectAtIndex:0];
			descriptionView.text = [NSString stringWithFormat:@"Take %@ - %@",
									 service.route.routeShortName,
									 service.route.routeLongName
									 ];
			descriptionView.text2 = [NSString stringWithFormat:@"At %@\nDeparted at %@",
									 service.begin.name,
									 service.begin.time
									 ];
			descriptionView.showsStopButton = YES;
			newFocusCoordinate = service.begin.coordinate;
		} else {
			CUService *service = [leg.services lastObject];
			descriptionView.text = [NSString stringWithFormat:@"Get off %@ - %@",
									service.route.routeShortName,
									service.route.routeLongName
									];
			descriptionView.text2 = [NSString stringWithFormat:@"At %@\nArrived at %@",
									 service.end.name,
									 service.end.time
									 ];
			descriptionView.showsStopButton = NO;
			newFocusCoordinate = service.end.coordinate;
		}
	}
	
	MKMapRect rect;
	if (step.coordinates.n == 1) {
		rect = optimalRectForCoordinates(step.coordinates.c1, step.coordinates.c1);
		const static double r = 1200.0;
		rect.origin.x -= r;
		rect.origin.y -= r;
		rect.size.width += r*2;
		rect.size.height += r*2;
	} else {
		rect = optimalRectForCoordinates(step.coordinates.c1, step.coordinates.c2);
		rect = mapRectWithEdgePadding(rect, UIEdgeInsetsMake(descriptionView.frame.size.height+20, 14, 20, 14), mapView);
	}
	
	if (order == ORDER_NEXT) {
		[mapView setVisibleMapRect:rect animated:YES];
	} else if (order == ORDER_PREV) {
		[UIView animateWithDuration:0.3 animations:^ {
			focus.coordinate = newFocusCoordinate;
		} completion:^(BOOL finished) {
			[mapView setVisibleMapRect:rect animated:YES];
		}];
	}
	
	[stepControl setEnabled:stepIndex > 0 forSegmentAtIndex:0];
	[stepControl setEnabled:stepIndex < [steps count]-1 forSegmentAtIndex:1];
	
	if (stepIndex < [steps count]-1)
		self.title = [NSString stringWithFormat:@"%d of %d", stepIndex+1, [steps count]-1];
	else
		self.title = @"End";
}

- (void)changeStep:(id)sender {
	NSInteger index = [sender selectedSegmentIndex];
	if (index == 0) {
		if (stepIndex-1 >= 0) {
			stepIndex--;
			[self updateStepWithAnimationOrder:ORDER_PREV];
			[self highlightStep:stepIndex];
		}
	} else if (index == 1) {
		if (stepIndex+1 < [steps count]) {
			stepIndex++;
			[self updateStepWithAnimationOrder:ORDER_NEXT];
			[self highlightStep:stepIndex];
		}
	}
}

// We imitate the bahavior of iOS's Maps app.
// There is one step for each walk.
// There are two steps for each service (start and end).
// There is one additional step at the end.
// So, we have a + 2b + 1 steps in total. (a is the # of walks and b is the # of services.)
- (void)createSteps {
	NSMutableArray *mutableSteps = [NSMutableArray array];
	
	StepCoordinates nextCoordinates = {1, ((CULeg*)[itinerary.legs objectAtIndex:0]).beginCoordinate};
	int nextHighlightedIndex = 0;
	
	for (NSUInteger i=0; i<[itinerary.legs count]; i++) {
		CULeg *leg = [itinerary.legs objectAtIndex:i];
		if (leg.type == CULegTypeWalk) {
			Step *step = [[Step alloc] init];
			step.legIndex = i;
			step.coordinates = nextCoordinates;
			step.highlightIndex = nextHighlightedIndex;
			[mutableSteps addObject:step];
			[step release];
			
			StepCoordinates coordinates = {2, leg.beginCoordinate, leg.endCoordinate};
			nextCoordinates = coordinates;
			nextHighlightedIndex = i;
		} else if (leg.type == CULegTypeService) {
			{
				Step *step = [[Step alloc] init];
				step.legIndex = i;
				step.serviceType = 0;
				step.coordinates = nextCoordinates;
				step.highlightIndex = nextHighlightedIndex;
				[mutableSteps addObject:step];
				[step release];
			}
			{
				Step *step = [[Step alloc] init];
				step.legIndex = i;
				step.serviceType = 1;
				StepCoordinates coordinates = {2, leg.beginCoordinate, leg.endCoordinate};
				step.coordinates = coordinates;
				step.highlightIndex = i;
				[mutableSteps addObject:step];
				[step release];
			}
			
			StepCoordinates coordinates = {1, leg.endCoordinate};
			nextCoordinates = coordinates;
			nextHighlightedIndex = -1;
		}
	}
	
	Step *step = [[Step alloc] init];
	step.legIndex = [itinerary.legs count]-1;
	step.isEnd = YES;
	step.coordinates = nextCoordinates;
	step.highlightIndex = nextHighlightedIndex;
	[mutableSteps addObject:step];
	[step release];
	
	self.steps = mutableSteps;
}

#pragma mark - MapView delegate

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id < MKAnnotation >)annotation {
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	
	// Focus
	if ([annotation isKindOfClass:[CUPoint class]]) {
		static NSString *annotationIdentifier = @"focus";
		PointAnnotationView *pinView = (PointAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
		if (!pinView) {
			pinView = [[[PointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
		} else {
			pinView.annotation = annotation;
		}
		
		return pinView;
	}
	
	// Leg
	if ([annotation isKindOfClass:[CULeg class]]) {
		static NSString *annotationIdentifier = @"leg";
		LegAnnotationView *pinView = (LegAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
		if (!pinView) {
			pinView = [[[LegAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
			pinView.canShowCallout = YES;
		} else {
			pinView.annotation = annotation;
		}
		
		CULeg *leg = annotation;
		if (leg.type == CULegTypeService) {
			UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			[rightButton addTarget:self action:@selector(showStop:) forControlEvents:UIControlEventTouchUpInside];
			pinView.rightCalloutAccessoryView = rightButton;
		} else {
			pinView.rightCalloutAccessoryView = nil;
		}
		
		return pinView;
	}

	// Stop
	static NSString *annotationIdentifier = @"stop";
	MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
	if (!pinView) {
		pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
		pinView.canShowCallout = YES;
	} else {
		pinView.annotation = annotation;
	}
	
	if (annotation == originLocation)
		pinView.pinColor = MKPinAnnotationColorGreen;
	else
		pinView.pinColor = MKPinAnnotationColorRed;
	
	return pinView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	ShapeView *view = [[ShapeView alloc] initWithOverlay:overlay];
	view.hidden = [(CUShape*)overlay hidden];
	return [view autorelease];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	if (!animated)
		return;
	if (newFocusCoordinate.latitude != focus.coordinate.latitude ||
		newFocusCoordinate.longitude != focus.coordinate.longitude) {
		[UIView beginAnimations:nil context:NULL];
		focus.coordinate = newFocusCoordinate;
		[UIView commitAnimations];
	}
}

- (void)mapView:(MKMapView *)_mapView didAddAnnotationViews:(NSArray *)views {
	MKAnnotationView *focusView = [mapView viewForAnnotation:focus];
	[focusView.superview sendSubviewToBack:focusView];
}

#pragma mark - StepDescriptionView delegate

- (void)stepDescriptionViewDidClickStopButton:(StepDescriptionView*)view {
	NSArray *legs = itinerary.legs;
	Step *step = [steps objectAtIndex:stepIndex];
	CULeg *leg = [legs objectAtIndex:step.legIndex];

	if (leg.type == CULegTypeService) {		
		if (step.serviceType == 0) {
			CUService *service = [leg.services objectAtIndex:0];
			CUStop *stop = [[CUStop alloc] init];
			stop.stopID = service.begin.stopID;
			stop.stopName = service.begin.name;
			stop.code = @"";
			stop.coordinate = service.begin.coordinate;
			StopController *controller = [[StopController alloc] initWithStop:stop];
			[self.navigationController pushViewController:controller animated:YES];
			[controller release];
			[stop release];
		}
	}
}

#pragma mark - Actions

- (void)showStop:(id)sender {
	MKPinAnnotationView *pinView = (MKPinAnnotationView*)[[sender superview] superview];
	CULeg *leg = pinView.annotation;
	if (leg.type == CULegTypeService) {
		CUService *service = [leg.services objectAtIndex:0];
		CUStop *stop = [[CUStop alloc] init];
		stop.stopID = service.begin.stopID;
		stop.stopName = service.begin.name;
		stop.code = @"";
		stop.coordinate = service.begin.coordinate;
		StopController *controller = [[StopController alloc] initWithStop:stop];
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
		[stop release];
	}
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)dealloc {
	[itinerary release];
	[originLocation release];
	[destinationLocation release];
	[mapView release];
	[descriptionView release];
	[stepControl release];
	[steps release];
	[shapes release];
	[highlightedShapes release];
	[focus release];
	[super dealloc];
}

@end
