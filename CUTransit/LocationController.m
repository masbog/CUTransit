//
//  BookmarkController.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "LocationController.h"
#import "common.h"
#import "Location.h"
#import "BookmarkDatabase.h"
#import "StopDatabase.h"

#define CURRENT_LOCATION_COLOR [UIColor colorWithRed:41/255.0f green:87/255.0f blue:1.0f alpha:1.0f]

@implementation LocationController

@synthesize delegate, bookmarksTableView, stopsTableView, bookmarkedStops, stopGroups, stopLetters, mapView, location, allowsCoordinateSelection;

- (void)setupBookmarksTableView {
	self.bookmarkedStops = [BookmarkDatabase stops];
	
	self.bookmarksTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	bookmarksTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	bookmarksTableView.dataSource = self;
	bookmarksTableView.delegate = self;
	[self.view addSubview:bookmarksTableView];
	[bookmarksTableView release];
}

- (void)setupStopsTableView {
	NSArray *stops = [StopDatabase sortedStops];
	self.stopGroups = [NSMutableArray array];
	self.stopLetters = [NSMutableArray array];
	unichar prevFirstLetter = 0;
	NSMutableArray *currentGroup;
	for (CUStop *stop in stops) {
		unichar firstLetter = [stop.stopName characterAtIndex:0];
		if (firstLetter != prevFirstLetter) {
			currentGroup = [NSMutableArray array];
			[stopGroups addObject:currentGroup];
			[stopLetters addObject:[NSString stringWithFormat:@"%C", firstLetter]];
			prevFirstLetter = firstLetter;
		}
		[currentGroup addObject:stop];
	}
	
	self.stopsTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
	stopsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	stopsTableView.dataSource = self;
	stopsTableView.delegate = self;
	[self.view addSubview:stopsTableView];
	[stopsTableView release];
}

- (void)setupMapView {
	self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
	mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	mapView.showsUserLocation = YES;
	mapView.delegate = self;
	[mapView setRegion:defaultRegion() animated:NO];
	[self.view addSubview:mapView];
	[mapView release];
	
	UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	[mapView addGestureRecognizer:recognizer];
	[recognizer release];
}

- (void)setupDoneButton {
	UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = bi;
	[bi release];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self setupDoneButton];
	
	self.title = @"Bookmarks";
	self.navigationItem.prompt = @"Choose a bookmark";
	
	[self setupBookmarksTableView];
	
	NSArray *items;
	if (allowsCoordinateSelection)
		items = [NSArray arrayWithObjects:@"Bookmarks", @"Stops", @"Map", nil];
	else
		items = [NSArray arrayWithObjects:@"Bookmarks", @"Stops", nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
	segmentedControl.frame = CGRectMake(0.0f, 0.0f, 308.0f, 30.0f);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.selectedSegmentIndex = 0;
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	UIBarButtonItem *a = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	[self setToolbarItems:[NSArray arrayWithObject:a] animated:NO];
	[a release];
	[segmentedControl release];
	
	self.navigationController.toolbarHidden = NO;
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

#pragma mark - Actions

- (void)done {
	if (mode == 2 && location) {
		location.text = [NSString stringWithFormat:@"%lf, %lf", location.coordinate.latitude, location.coordinate.longitude];
		[delegate locationController:self didSelectLocation:location];
	}
	
	[((UIViewController*)delegate) dismissModalViewControllerAnimated:YES];
}

- (void)segmentAction:(id)sender {
	UISegmentedControl *segmentedControl = sender;
	
	if (mode == 0 && bookmarksTableView.isEditing) {
		[self setEditing:NO animated:NO];
	}
	mode = segmentedControl.selectedSegmentIndex;
	
	if (mode == 0) {
		self.title = @"Bookmarks";
		[self.navigationItem setPrompt:@"Choose a bookmark"];
		[self.view bringSubviewToFront:bookmarksTableView];
		self.navigationItem.leftBarButtonItem = self.editButtonItem;
	} else if (mode == 1) {
		self.title = @"Stops";
		[self.navigationItem setPrompt:@"Choose a bus stop"];
		if (!stopsTableView) {
			[self setupStopsTableView];
		}
		self.navigationItem.leftBarButtonItem = nil;
		[self.view bringSubviewToFront:stopsTableView];
		
	} else if (mode == 2) {
		self.title = @"Map";
		self.navigationItem.prompt = @"Tap and hold to choose a location";
		if (!mapView) {
			[self setupMapView];
		}
		self.navigationItem.leftBarButtonItem = nil;
		[self.view bringSubviewToFront:mapView];
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	if (mode == 0) {
		[bookmarksTableView setEditing:editing animated:animated];
		if (editing) {
			[self.navigationItem setRightBarButtonItem:nil animated:YES];
		} else {
			[self setupDoneButton];
		}
	}
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)sender {
	if (sender.state == UIGestureRecognizerStateBegan) {
		CGPoint point = [sender locationInView:mapView];
		CLLocationCoordinate2D coordinate = [mapView convertPoint:point toCoordinateFromView:mapView];
		
		if (location)
			[mapView removeAnnotation:location];
		
		self.location = [[[Location alloc] init] autorelease];
		location.type = LocationTypeCoordinate;
		location.coordinate = coordinate;
		[mapView addAnnotation:location];
	}
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (tableView == bookmarksTableView) {
		return allowsCoordinateSelection ? 2 : 1;
	} else if (tableView == stopsTableView) {
		return [stopGroups count];
	}
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == bookmarksTableView) {
		if (allowsCoordinateSelection && section==0)
			return 1;
		return [bookmarkedStops count];
	} else if (tableView == stopsTableView) {
		return [[stopGroups objectAtIndex:section] count];
	}
	return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [stopLetters objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return stopLetters;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == bookmarksTableView) {
		static NSString *cellIdentifier = @"Cell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		}
		if (allowsCoordinateSelection && indexPath.section == 0) {
			cell.textLabel.text = @"Current Location";
			cell.textLabel.textColor = CURRENT_LOCATION_COLOR;
		} else {
			CUStop *stop = [bookmarkedStops objectAtIndex:indexPath.row];
			cell.textLabel.text = stop.stopName;
			cell.textLabel.textColor = [UIColor blackColor];
		}
		return cell;
	} else if (tableView == stopsTableView) {
		static NSString *cellIdentifier = @"Cell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
		}
		CUStop *stop = [[stopGroups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		cell.textLabel.text = stop.stopName;
		cell.detailTextLabel.text = stop.code;
		return cell;
	}
	return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == bookmarksTableView) {
		if (allowsCoordinateSelection)
			return indexPath.section == 1;
		return YES;
	}
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		CUStop *stop = [bookmarkedStops objectAtIndex:indexPath.row];
		[BookmarkDatabase removeStop:stop];
		
		[bookmarkedStops removeObjectAtIndex:indexPath.row];
		
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	if (tableView == bookmarksTableView) {
		NSDictionary *tmp = [[bookmarkedStops objectAtIndex:fromIndexPath.row] retain];
		[bookmarkedStops removeObjectAtIndex:fromIndexPath.row];
		[bookmarkedStops insertObject:tmp atIndex:toIndexPath.row];
		[tmp release];
		
		[BookmarkDatabase reorderStops:bookmarkedStops];
	}
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == bookmarksTableView) {
		if (allowsCoordinateSelection && indexPath.section == 0) {
			Location *loc = [[Location alloc] init];
			loc.type = LocationTypeCurrentLocation;
			loc.text = @"Current Location";
			[delegate locationController:self didSelectLocation:loc];
			[loc release];
		} else {
			CUStop *stop = [bookmarkedStops objectAtIndex:indexPath.row];
			Location *loc = [[Location alloc] init];
			loc.type = LocationTypeStop;
			loc.stop = stop;
			loc.text = stop.stopName;
			[delegate locationController:self didSelectLocation:loc];
			[loc release];
		}
	} else if (tableView == stopsTableView) {
		CUStop *stop = [[stopGroups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		Location *loc = [[Location alloc] init];
		loc.type = LocationTypeStop;
		loc.stop = stop;
		loc.text = stop.stopName;
		[delegate locationController:self didSelectLocation:loc];
		[loc release];
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
	   toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	if (sourceIndexPath.section == 1) {
		if (proposedDestinationIndexPath.section < 1)
			return [NSIndexPath indexPathForRow:0 inSection:1];
		
	}
	return proposedDestinationIndexPath;
}

#pragma mark - MapView delegate

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id < MKAnnotation >)annotation {
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	
	static NSString *annotationIdentifier = @"stop";
	MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
	if (!pinView) {
		pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
		pinView.animatesDrop = YES;
		pinView.draggable = YES;
		pinView.pinColor = MKPinAnnotationColorPurple;
	} else {
		pinView.annotation = annotation;
	}

	return pinView;
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return YES;
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)dealloc {
	[bookmarksTableView release];
	[stopsTableView release];
	[bookmarkedStops release];
	[stopGroups release];
	[stopLetters release];
	[mapView release];
	[location release];
	[super dealloc];
}

@end
