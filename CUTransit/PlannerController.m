//
//  SecondViewController.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "PlannerController.h"
#import "common.h"
#import "ShapeView.h"
#import "ItineraryController.h"
#import "Location.h"
#import "StepCell.h"
#import "LocationTextField.h"

#define TITLE @"Trip Planner"
#define CURRENT_LOCATION_COLOR [UIColor colorWithRed:41/255.0f green:87/255.0f blue:1.0f alpha:1.0f]


@implementation PlannerController

@synthesize startTextField, endTextField, resultsTableView, swapButton, searchCancelView, routeButton,  itinerariesTableView, loadingView, spinView;
@synthesize searchResults, originLocation, destinationLocation, itineraries;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = TITLE;
		
		self.originLocation = [[[Location alloc] init] autorelease];
		self.destinationLocation = [[[Location alloc] init] autorelease];
		
		originLocation.type = LocationTypeText;
		originLocation.text = @"";
		
		destinationLocation.type = LocationTypeText;
		destinationLocation.text = @"";
    }
    return self;
}

#pragma mark - Other

- (void)processLegs {
	// set text & height for each leg
	for (CUItinerary *itinerary in itineraries) {
		for (CULeg *leg in itinerary.legs) {
			if (leg.type == CULegTypeWalk) {
				CUWalk *walk = leg.walk;
				leg.text = [NSString stringWithFormat:@"Walk to |^%@\n|$%.2f miles",
							walk.end.name,
							walk.distance
							];
				leg.rowHeight = [StepCell heightForText:leg.text];
			} else if (leg.type == CULegTypeService) {
				CUService *service = [leg.services objectAtIndex:0];
				CUService *service2 = [leg.services lastObject];
				leg.text = [NSString stringWithFormat:@"Take |@%@ - %@|\nfrom |^%@\n|$%@|\nto |^%@\n|$%@",
							service.route.routeShortName,
							service.route.routeLongName,
							service.begin.name,
							service.begin.time,
							
							service2.end.name,
							service2.end.time
							];
				leg.rowHeight = [StepCell heightForText:leg.text];
			}
		}
	}
}

- (void)addCancelButton {
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSearch:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
}

- (void)removeCancelButton {
	self.navigationItem.leftBarButtonItem = nil;
}

- (void)showLoading {
	loadingView.hidden = NO;
	[spinView startAnimating];
}

- (void)hideLoading {
	loadingView.hidden = YES;
	[spinView stopAnimating];
}

#pragma mark - Actions

- (void)route {
	if (originLocation.type == LocationTypeStop && destinationLocation.type == LocationTypeStop) {
		CUConnection *con = [CUConnection sharedConnection];
		[con requestPlannedTripsByOriginStopID:originLocation.stop.stopID
							 destinationStopID:destinationLocation.stop.stopID
									   handler:
		 ^(id data, CUError *error) {
			 if (data) {
				 self.itineraries = data;
				 
				 dispatch_async(dispatch_get_main_queue(), ^{
					 [self processLegs];
					 
					 [itinerariesTableView reloadData];
					 [self hideLoading];
					 routeButton.enabled = YES;
					 if ([itineraries count] == 0) {
						 handleCommonError(error);
					 }
				 });
			 } else {
				 dispatch_async(dispatch_get_main_queue(), ^{
					 handleCommonError(error);
					 [self hideLoading];
					 routeButton.enabled = YES;
				 });
			 }
		 }
		 ];
	} else {
		CLLocationCoordinate2D originCoordinate = (originLocation.type == LocationTypeStop) ? originLocation.stop.coordinate : originLocation.coordinate;
		CLLocationCoordinate2D destinationCoordinate = (destinationLocation.type == LocationTypeStop) ? destinationLocation.stop.coordinate : destinationLocation.coordinate;
		
		CUConnection *con = [CUConnection sharedConnection];
		[con requestPlannedTripsByOriginCoordinate:originCoordinate
							 destinationCoordinate:destinationCoordinate
										   handler:
		 ^(id data, CUError *error) {
			 if (data) {
				 self.itineraries = data;
				 
				 dispatch_async(dispatch_get_main_queue(), ^{
					 // change coordinates to user-friendly name
					 for (CUItinerary *itinerary in itineraries) {
						 CULeg *leg = [itinerary.legs lastObject];
						 if (leg.type == CULegTypeWalk) {
							 CUWalk *walk = leg.walk;
							 walk.end.name = destinationLocation.text;
						 }
					 }
					 
					 [self processLegs];
					 
					 [itinerariesTableView reloadData];
					 [self hideLoading];
					 routeButton.enabled = YES;
					 if ([itineraries count] == 0) {
						 handleCommonError(error);
					 }
				 });
			 } else {
				 dispatch_async(dispatch_get_main_queue(), ^{
					 handleCommonError(error);
					 [self hideLoading];
					 routeButton.enabled = YES;
				 });
			 }
		 }
		 ];
	}
}

- (void)routeAction:(id)sender {
	[startTextField resignFirstResponder];
	[endTextField resignFirstResponder];
	
	[self showLoading];
	routeButton.enabled = NO;
	
	self.itineraries = nil;
	[itinerariesTableView reloadData];
	
	[originLocation resolveWithHandler:^(BOOL success, NSError *error) {
		if (success) {
			[destinationLocation resolveWithHandler:^(BOOL success, NSError *error) {
				if (success) {
					dispatch_async(dispatch_get_main_queue(), ^{
						//startTextField.text = originLocation.text;
						//endTextField.text = destinationLocation.text;
						startTextField.location = originLocation;
						endTextField.location = destinationLocation;
					});

					[self route];
				} else {
					dispatch_async(dispatch_get_main_queue(), ^{
						alert(@"Can't determine the destination", error.localizedDescription);
						[self hideLoading];
						routeButton.enabled = YES;
					});
				}
			}];
		} else {
			dispatch_async(dispatch_get_main_queue(), ^{
				alert(@"Can't determine the origin", error.localizedDescription);
				[self hideLoading];
				routeButton.enabled = YES;
			});
		}
	}];
}

- (IBAction)cancelSearch:(id)sender {
	[startTextField resignFirstResponder];
	[endTextField resignFirstResponder];
}

- (void)switchLocations:(id)sender {
	Location *tmp = originLocation;
	originLocation = destinationLocation;
	destinationLocation = tmp;
	
	disableSearchStringChanged = YES;
	startTextField.location = originLocation;
	endTextField.location = destinationLocation;
	disableSearchStringChanged = NO;
	
	if (selectedTextField) {
		resultsTableView.alpha = 0;
		searchCancelView.alpha = 1;
	}
	
	if ([startTextField isFirstResponder])
		[endTextField becomeFirstResponder];
	else if ([endTextField isFirstResponder])
		[startTextField becomeFirstResponder];
}

- (void)bookmarkAction:(id)sender {
	LocationController *controller = [[LocationController alloc] init];
	controller.allowsCoordinateSelection = YES;
	controller.delegate = self;
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
	[self presentModalViewController:nav animated:YES];
	[nav release];
	[controller release];

}

- (void)showDirectionsWithStop:(CUStop*)stop isOrigin:(BOOL)isOrigin {
	[self view];
	
	if (isOrigin) {
		originLocation.type = LocationTypeStop;
		originLocation.stop = stop;
		originLocation.text = stop.stopName;
		
		destinationLocation.type = LocationTypeText;
		destinationLocation.text = @"";
	} else {
		originLocation.type = LocationTypeCurrentLocation;
		originLocation.text = @"Current Location";
		
		destinationLocation.type = LocationTypeStop;
		destinationLocation.stop = stop;
		destinationLocation.text = stop.stopName;
	}
	
	disableSearchStringChanged = YES;
	startTextField.location = originLocation;
	endTextField.location = destinationLocation;
	disableSearchStringChanged = NO;
	
	[endTextField becomeFirstResponder];
	
	routeButton.enabled = [startTextField.text length] > 0 && [endTextField.text length] > 0;
	swapButton.enabled = [startTextField.text length] > 0 || [endTextField.text length] > 0;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	// Text fields
	startTextField.label.text = @"Start: ";
	endTextField.label.text = @"End: ";
	[startTextField.bookmarkButton addTarget:self action:@selector(bookmarkAction:) forControlEvents:UIControlEventTouchUpInside];
	[endTextField.bookmarkButton addTarget:self action:@selector(bookmarkAction:) forControlEvents:UIControlEventTouchUpInside];
	[startTextField setLocation:originLocation];
	[endTextField setLocation:destinationLocation];

	// Route button
	self.routeButton = [[UIBarButtonItem alloc] initWithTitle:@"Route" style:UIBarButtonItemStyleDone target:self action:@selector(routeAction:)];
	self.navigationItem.rightBarButtonItem = routeButton;
	routeButton.enabled = [startTextField.text length] > 0 && [endTextField.text length] > 0;
	[routeButton release];
	
	// Swap button
	UIImage *swapButtonBgImage = [[UIImage imageNamed:@"button"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f];
	UIImage *swapButtonPressedBgImage = [[UIImage imageNamed:@"button_pressed"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f];
	UIImage *swapButtonImage = [[UIImage imageNamed:@"directions_swap"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f];
	self.swapButton = [UIButton buttonWithType:UIButtonTypeCustom];
	swapButton.frame = CGRectMake(4, 24, 31, 30);
	[swapButton setBackgroundImage:swapButtonBgImage forState:UIControlStateNormal];
	[swapButton setBackgroundImage:swapButtonPressedBgImage forState:UIControlStateHighlighted];
	[swapButton setImage:swapButtonImage forState:UIControlStateNormal];
	[swapButton addTarget:self action:@selector(switchLocations:) forControlEvents:UIControlEventTouchUpInside];
	swapButton.enabled = [startTextField.text length] > 0 || [endTextField.text length] > 0;
	[self.view addSubview:swapButton];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.routeButton = nil;
	self.swapButton = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[itinerariesTableView deselectRowAtIndexPath:itinerariesTableView.indexPathForSelectedRow animated:YES];
}

#pragma mark - TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (tableView == resultsTableView)
		return 2;
	if (tableView == itinerariesTableView)
		return [itineraries count];
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (tableView == itinerariesTableView)
		return [NSString stringWithFormat:@"Itinerary %d", section+1];
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == resultsTableView) {
		if (section == 0)
			return showsCurrentLocationResult ? 1 : 0;
		if (section == 1)
			return [searchResults count];
	} else if (tableView == itinerariesTableView) {
		if (section < [itineraries count]) {
			CUItinerary *itinerary = [itineraries objectAtIndex:section];
			return [itinerary.legs count];
		}
		return 0;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == resultsTableView) {
		if (indexPath.section == 0) {
			static NSString *cellIdentifier = @"Cell2";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
				cell.textLabel.text = @"Current Location";
				cell.textLabel.textColor = CURRENT_LOCATION_COLOR;
			}
			return cell;
		} else if (indexPath.section == 1) {
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
	} else if (tableView == itinerariesTableView) {
		static NSString *cellIdentifier = @"Cell";
		StepCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[[StepCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		}
		
		NSUInteger section = indexPath.section;
		NSUInteger row = indexPath.row;
		
		if (section < [itineraries count]) {
			CUItinerary *itinerary = [itineraries objectAtIndex:section];
			NSArray *legs = itinerary.legs;
			if (row < [legs count]) {
				CULeg *leg = [legs objectAtIndex:row];
				cell.stepView.text = leg.text;
				cell.stepView.type = leg.type;
			}
		}
		
		return cell;
	}
	return nil;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == resultsTableView) {
		if (indexPath.section == 0) {
			selectedLocation.type = LocationTypeCurrentLocation;
			selectedLocation.text = @"Current Location";
			
			disableSearchStringChanged = YES;
			selectedTextField.location = selectedLocation;
			disableSearchStringChanged = NO;
		} else if (indexPath.section == 1) {
			if (indexPath.row < [searchResults count]) {
				CUStop *stop = [searchResults objectAtIndex:indexPath.row];
				
				selectedLocation.type = LocationTypeStop;
				selectedLocation.stop = stop;
				selectedLocation.text = stop.stopName;
				
				disableSearchStringChanged = YES;
				selectedTextField.location = selectedLocation;
				disableSearchStringChanged = NO;
			}
		}
		if (selectedTextField == startTextField) {
			[endTextField becomeFirstResponder];
		} else {
			[self textFieldShouldReturn:endTextField];
		}
	} else if (tableView == itinerariesTableView) {
		CUItinerary *itinerary = [itineraries objectAtIndex:indexPath.section];
		
		ItineraryController *controller = [[ItineraryController alloc] initWithItinerary:itinerary originLocation:originLocation destinationLocation:destinationLocation];
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == itinerariesTableView) {
		NSUInteger section = indexPath.section;
		NSUInteger row = indexPath.row;
		
		if (section < [itineraries count]) {
			CUItinerary *itinerary = [itineraries objectAtIndex:section];
			NSArray *legs = itinerary.legs;
			if (row < [legs count]) {
				CULeg *leg = [legs objectAtIndex:row];
				return leg.rowHeight;
			}
		}
	}
	return tableView.rowHeight;
}

#pragma mark - TextView actions

- (IBAction)searchStringChanged:(id)sender {
	if (disableSearchStringChanged)
		return;
	
	NSString *searchString = [sender text];
	searchTimestamp++;
	
	routeButton.enabled = [startTextField.text length] > 0 && [endTextField.text length] > 0;
	swapButton.enabled = [startTextField.text length] > 0 || [endTextField.text length] > 0;
	
	if ([searchString length] == 0) {
		self.searchResults = nil;
		selectedLocation.type = LocationTypeText;
		selectedLocation.text = @"";
		
		[resultsTableView reloadData];
		resultsTableView.alpha = 0;
		searchCancelView.alpha = 1;
		return;
	}
		
	selectedLocation.type = LocationTypeText;
	selectedLocation.text = searchString;
	selectedTextField.textColor = [UIColor blackColor];
	
	if (sender != selectedTextField)
		return;
	
	showsCurrentLocationResult = (sender == selectedTextField) &&
	([@"current location" hasPrefix:[selectedTextField.text lowercaseString]] ||
	  [@"where i am" hasPrefix:[selectedTextField.text lowercaseString]]);
	
	if ([searchResults count] > 0 || showsCurrentLocationResult) {
		resultsTableView.alpha = 1;
		searchCancelView.alpha = 0;
	} else {
		resultsTableView.alpha = 0;
		searchCancelView.alpha = 1;
	}
	
	[resultsTableView reloadData];
	
	int localSearchTimestamp = searchTimestamp;
	CUConnection *con = [CUConnection sharedConnection];
	[con requestStopsBySearch:searchString handler:
	 ^(id data, CUError *error) {
		 if (!data)
			 return;
		 dispatch_async(dispatch_get_main_queue(), ^{
			 if (sender != selectedTextField)
				 return;
			 if (localSearchTimestamp != searchTimestamp)
				 return;
			 
			 NSArray *stops = data;
			 self.searchResults = stops;
			 
			 if ([stops count] > 0 || showsCurrentLocationResult) {
				 resultsTableView.alpha = 1;
				 searchCancelView.alpha = 0;
			 } else {
				 resultsTableView.alpha = 0;
				 searchCancelView.alpha = 1;
			 }
			 
			 [resultsTableView reloadData];
			 [resultsTableView setContentOffset:CGPointZero];
		 });
	 }
	 ];
}

#pragma mark - TextView delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	selectedTextField = (LocationTextField*)textField;
	if (textField == startTextField)
		selectedLocation = originLocation;
	else if (textField == endTextField)
		selectedLocation = destinationLocation;
	
	if (([startTextField isFirstResponder] && textField == endTextField) ||
		([endTextField isFirstResponder] && textField == startTextField)) {
		// The user is moving the cursor from one text field to another text field.
		disableAnimation = YES;
		
		resultsTableView.alpha = 0;
		searchCancelView.alpha = 1;
	} else {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.25];
		searchCancelView.alpha = 1;
		[UIView commitAnimations];
		
		[self addCancelButton];
	}
	
	if (textField == startTextField) {
	} else if (textField == endTextField) {
		if ([startTextField.text length] > 0) {
			endTextField.returnKeyType = UIReturnKeyRoute;
			endTextField.enablesReturnKeyAutomatically = YES;
		} else {
			endTextField.returnKeyType = UIReturnKeyNext;
			endTextField.enablesReturnKeyAutomatically = NO;
		}
	}
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (disableAnimation) {
		disableAnimation = NO;
	} else {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.25];
		resultsTableView.alpha = 0;
		searchCancelView.alpha = 0;
		[UIView commitAnimations];
		
		selectedTextField = nil;
		
		[self removeCancelButton];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == startTextField) {
		[endTextField becomeFirstResponder];
	} else if (textField == endTextField) {
		if (textField.returnKeyType == UIReturnKeyNext) {
			[startTextField becomeFirstResponder];
		} else {
			[self routeAction:nil];
		}
	}
	return YES;
}

#pragma mark - LocationController delegate

- (void)locationController:(LocationController*)controller didSelectLocation:(Location*)location {
	[self dismissModalViewControllerAnimated:YES];
	
	disableSearchStringChanged = YES;
	if ([startTextField isFirstResponder]) {
		self.originLocation = location;
		selectedLocation = originLocation;
		startTextField.location = originLocation;
	} else if ([endTextField isFirstResponder]) {
		self.destinationLocation = location;
		selectedLocation = destinationLocation;
		endTextField.location = destinationLocation;
	}
	disableSearchStringChanged = NO;
	
	routeButton.enabled = [startTextField.text length] > 0 && [endTextField.text length] > 0;
	swapButton.enabled = [startTextField.text length] > 0 || [endTextField.text length] > 0;
	
	[self textFieldShouldReturn:selectedTextField];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return YES;
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)dealloc {
	[startTextField release];
	[endTextField release];
	[resultsTableView release];
	[swapButton release];
	[searchCancelView release];
	[routeButton release];
	[itinerariesTableView release];
	[loadingView release];
	[spinView release];
	
	[searchResults release];
	[originLocation release];
	[destinationLocation release];
	[itineraries release];
	[super dealloc];
}

@end
