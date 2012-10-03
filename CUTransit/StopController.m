//
//  StopController.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "StopController.h"
#import "AppDelegate.h"
#import "BookmarkDatabase.h"
#import "common.h"
#import "DepartureController.h"
#import "TitleView.h"
#import "DepartureCell.h"

#define TITLE_COLOR [UIColor colorWithRed:81/255.0f green:102/255.0f blue:145/255.0f alpha:1.0f]
#define MAX_REPEATS 10
#define REPEAT_INTERVAL 55


@implementation StopController

@synthesize stop, infoTableView, departureTableView, showsDepartureFirst, address, departures, refreshButton;

- (id)initWithStop:(CUStop*)s {
	self = [super init];
	if (self) {
		self.stop = s;
		self.title = s.stopName;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Segmented control
	NSArray *items = [NSArray arrayWithObjects:@"Info", @"Departures", nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
	segmentedControl.frame = CGRectMake(0, 0, self.view.frame.size.width, 44.0f);
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	segmentedControl.segmentedControlStyle = 7; // undocumented style
	segmentedControl.selectedSegmentIndex = showsDepartureFirst ? 1 : 0;
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:segmentedControl];
	[segmentedControl release];
	
	if (!showsDepartureFirst) {
		[self showInfo];
	} else {
		[self setupTitleView];
		[self setupRefreshButton];
		[self showDepartures];
	}
}

- (void)updateBookmarkButton {
	if ([BookmarkDatabase hasStop:stop]) {
		[bookmarkButton setTitle:@"Remove from Bookmarks" forState:UIControlStateNormal];
	} else {
		[bookmarkButton setTitle:@"Add to Bookmarks" forState:UIControlStateNormal];
	}
}

- (void)setupTitleView {
	if (!titleView) {
		titleView = [[TitleView alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
		titleView.text = stop.stopName;
	}
	self.navigationItem.titleView = titleView;
}

- (void)hideTitleView {
	self.navigationItem.titleView = nil;
}

- (void)setupRefreshButton {
	if (!refreshButton) {
		self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
		refreshButton.style = UIBarButtonItemStyleBordered;
		[refreshButton release];
	}
	self.navigationItem.rightBarButtonItem = refreshButton;
}

- (void)hideRefreshButton {
	self.navigationItem.rightBarButtonItem = nil;
}

- (void)showInfo {
	self.infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f) style:UITableViewStyleGrouped];
	infoTableView.backgroundColor = [UIColor colorWithRed:0.851f green:0.851f blue:0.878f alpha:1.0f];
	infoTableView.backgroundView = nil;
	infoTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	infoTableView.dataSource = self;
	infoTableView.delegate = self;
	
	[self.view addSubview:infoTableView];
	[infoTableView release];
	
	CLLocation *location = [[CLLocation alloc] initWithLatitude:stop.coordinate.latitude longitude:stop.coordinate.longitude];
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
		if ([placemarks count] > 0) {
			CLPlacemark *placemark = [placemarks objectAtIndex:0];
			self.address = [NSString stringWithFormat:@"%@ %@\n%@, %@ %@",
							placemark.subThoroughfare,
							placemark.thoroughfare,
							placemark.locality,
							placemark.administrativeArea,
							placemark.postalCode
							];
			[infoTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
		}
	}];
	[geocoder release];
	[location release];
}

- (void)showDepartures {
	self.departureTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f) style:UITableViewStylePlain];
	departureTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	departureTableView.dataSource = self;
	departureTableView.delegate = self;
	[self.view addSubview:departureTableView];
	[departureTableView release];
	
	[self refresh];
	[self resetTimer];
}

- (void)resetTimer {
	[timer invalidate];
	nRepeats = MAX_REPEATS;
	timer = [NSTimer scheduledTimerWithTimeInterval:REPEAT_INTERVAL target:self selector:@selector(scheduledRefresh:) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
	if (self.parentViewController == nil) { // the view controller has been popped from the stack
		[timer invalidate];
		timer = nil;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.departureTableView deselectRowAtIndexPath:[departureTableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Actions

- (void)segmentAction:(id)sender {
	UISegmentedControl *segmentedControl = sender;
	
	NSInteger index = segmentedControl.selectedSegmentIndex;
	if (index == 0) {
		[self hideTitleView];
		[self hideRefreshButton];
		if (!infoTableView)
			[self showInfo];
		[self.view bringSubviewToFront:infoTableView];
	} else if (index == 1) {
		[self setupTitleView];
		[self setupRefreshButton];
		if (!departureTableView)
			[self showDepartures];
		[self.view bringSubviewToFront:departureTableView];
		
	}
}

- (void)shareAction:(id)sender {
	// check if it's iOS 6
	if ([[UIDevice currentDevice].systemVersion compare:@"6" options:NSNumericSearch] != NSOrderedAscending) {
		NSArray *items = @[
		stop.stopName,
		[NSURL URLWithString:
		 [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@&ll=%lf,%lf",
		  [stop.stopName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
		  stop.coordinate.latitude,
		  stop.coordinate.longitude
		  ]]
		];
		UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
		controller.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard];
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			CGRect rect = [self.view convertRect:((UIButton*)sender).bounds fromView:sender];
			
			UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
			popover.delegate = self;
			[popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
		} else {
			[self presentModalViewController:controller animated:YES];
		}
		
		[controller release];
	} else {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share Location Using:"
																 delegate:self
														cancelButtonTitle:nil
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Email", nil];
		if ([MFMessageComposeViewController canSendText]) {
			[actionSheet addButtonWithTitle:@"Message"];
		}
		[actionSheet addButtonWithTitle:@"Cancel"];
		actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			[actionSheet showFromRect:[self.view convertRect:[sender bounds] fromView:sender] inView:self.view animated:NO];
		else
			[actionSheet showInView:self.tabBarController.tabBar];
		[actionSheet release];
	}
}

- (void)bookmarkAction:(id)sender {
	if (![BookmarkDatabase hasStop:stop]) {
		[BookmarkDatabase addStop:stop];
	} else {
		[BookmarkDatabase removeStop:stop];
	}
	[self updateBookmarkButton];
}

#pragma mark - Actions

- (void)refresh {
	if (isLoading)
		return;
	
	titleView.text2 = @"Loading...";
	refreshButton.enabled = NO;
	isLoading = YES;
	
	CUConnection *con = [CUConnection sharedConnection];
	[con requestDeparturesByStopID:stop.stopID lookAhead:looksAhead handler:
	 ^(id data, CUError *error) {
		 if (data) {
			 dispatch_async(dispatch_get_main_queue(), ^{
				 self.departures = data;
				 
				 [titleView setUpdated];
				 refreshButton.enabled = YES;
				 isLoading = NO;
				 
				 [self.departureTableView reloadData];
			 });
		 } else {
			 dispatch_async(dispatch_get_main_queue(), ^{
				 if (self.isViewLoaded && self.view.window) // show error only if the view is visible
					 handleCommonError(error);
				 [titleView setUpdated];
				 refreshButton.enabled = YES;
				 isLoading = NO;
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
	if (nRepeats > 0) {
		[self refresh];
		nRepeats--;
	} else {
		[timer invalidate];
		timer = nil;
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (tableView == infoTableView) {
		return 2;
	} else if (tableView == departureTableView) {
		return 2;
	}
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == infoTableView) {
		if (section == 0)
			return 1;
		if (section == 1)
			return 3;
	} else if (tableView == departureTableView) {
		if (section == 0) {
			if ([departures count] == 0 && !isLoading)
				return 4;
			return [departures count];
		}
		if (section == 1)
			return (looksAhead || isLoading) ? 0 : 1;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == infoTableView) {
		NSUInteger row = indexPath.row;
		
		if (indexPath.section == 0 || (indexPath.section == 1 && row == 0)) {
			static NSString *CellIdentifier = @"Cell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
				cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
				cell.textLabel.textColor = TITLE_COLOR;
				cell.detailTextLabel.numberOfLines = 0;
			}
			
			if (indexPath.section == 0) {
				cell.textLabel.text = @"Stop ID";
				cell.detailTextLabel.text = stop.code;
			} else {
				cell.textLabel.text = @"Address";
				cell.detailTextLabel.text = address ? address : @"\n\n";
			}
			return cell;
		} else {
			
			static NSString *CellIdentifier = @"Cell2";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
				cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];
				cell.textLabel.textColor = TITLE_COLOR;
				cell.textLabel.textAlignment = UITextAlignmentCenter;
			}
			
			if (row == 1) {
				cell.textLabel.text = @"Directions To Here";
			} else {
				cell.textLabel.text = @"Directions From Here";
			}
			return cell;
		}
		
	} else if (tableView == departureTableView) {
		if (indexPath.section == 0) {
			if ([departures count] == 0) {
				NSUInteger row = indexPath.row;
				UITableViewCell *cell = [[[UITableViewCell alloc] init] autorelease];
				if (row == 3) {
					cell.textLabel.text = @"No Buses";
					cell.textLabel.textColor = [UIColor grayColor];
					cell.textLabel.textAlignment = UITextAlignmentCenter;
				}
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				return cell;
			}
			
			{
				static NSString *cellIdentifier = @"Cell";
				DepartureCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
				if (cell == nil) {
					cell = [[[DepartureCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
				}
				
				CUDeparture *departure = [departures objectAtIndex:indexPath.row];
				cell.departure = departure;
				
				return cell;
			}
			
		} else if (indexPath.section == 1) {
			static NSString *cellIdentifier = @"Cell2";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
			}
			
			cell.textLabel.text = @"Look ahead 60 minutes";
			cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
			cell.textLabel.textColor = [UIColor colorWithRed:36/255.0f green:112/255.0f blue:216/255.0f alpha:1.0f];
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			return cell;
		}
	}
	return nil;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == infoTableView) {
		if (indexPath.section == 1 && indexPath.row == 0)
			return 60.0f;
	}
	return tableView.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (tableView == infoTableView) {
		if (section != 1)
			return 0.0f;
		return 59.0f;
	}
	return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (tableView == infoTableView) {
		if (section != 1)
			return nil;
		
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 59.0f)];
		{
			UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			button.frame = CGRectMake(9, 15, 146, 44);
			button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
			[button setTitle:@"Share Location" forState:UIControlStateNormal];
			[button setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
			[button addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
			button.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
			
			[view addSubview:button];
		}
		{
			UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			bookmarkButton = button;
			button.frame = CGRectMake(320-9-146, 15, 146, 44);
			button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
			//[button setTitle:@"Add to Bookmarks" forState:UIControlStateNormal];
			[button setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
			[button addTarget:self action:@selector(bookmarkAction:) forControlEvents:UIControlEventTouchUpInside];
			button.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
			button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
			button.titleLabel.numberOfLines = 0;
			button.titleLabel.textAlignment = UITextAlignmentCenter;
			
			[self updateBookmarkButton];
			[view addSubview:button];
		}
		
		return [view autorelease];
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == infoTableView) {
		if (indexPath.section == 0) {
			if ([MFMessageComposeViewController canSendText]) {
				MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
				controller.messageComposeDelegate = self;
				controller.body = stop.code;
				controller.recipients = @[@"35890"];
				[self presentModalViewController:controller animated:YES];
				[controller release];
			}
		} else {
			if (indexPath.row == 0) {
				AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
				[appDelegate showStop:stop];
			} else {
				AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
				[appDelegate showDirectionsWithStop:stop isOrigin:indexPath.row == 2];
			}
		}
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
	} else if (tableView == departureTableView) {
		if (indexPath.section == 0) {
			if (indexPath.row < [departures count]) {
				CUDeparture *departure = [departures objectAtIndex:indexPath.row];
				DepartureController *controller = [[DepartureController alloc] initWithDeparture:departure stop:stop];
				controller.looksAhead = looksAhead;
				[self.navigationController pushViewController:controller animated:YES];
				[controller release];
			}
		} else if (indexPath.section == 1) {
			[tableView deselectRowAtIndexPath:indexPath animated:NO];
			looksAhead = YES;
			[self refreshAction:nil];
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == infoTableView) {
		return indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0);
	}
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	if (tableView == infoTableView) {
		if (indexPath.section == 0) {
			[[UIPasteboard generalPasteboard] setString:stop.stopName];
		} else if (indexPath.section == 1 && indexPath.row == 0) {
			[[UIPasteboard generalPasteboard] setString:address];
		}
	}
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex >= actionSheet.numberOfButtons) // user clicks the cancel button
		return;
	
	if (buttonIndex == 0) {
		if ([MFMailComposeViewController canSendMail]) {
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			[picker setSubject:stop.stopName];
			NSString *body = [NSString stringWithFormat:@"<a href=\"http://maps.google.com/maps?q=%@&ll=%lf,%lf\">%@</a>",
							  [stop.stopName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							  stop.coordinate.latitude,
							  stop.coordinate.longitude,
							  stop.stopName
							  ];
			[picker setMessageBody:body isHTML:YES];
			[self presentModalViewController:picker animated:YES];
			[picker release];
		} else {
			// this prompts the user to add email account
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"]];
		}
	} else if (buttonIndex == 1) {
		if ([MFMessageComposeViewController canSendText]) {
			MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
			controller.messageComposeDelegate = self;
			NSString *body = [NSString stringWithFormat:@"%@ http://maps.google.com/maps?q=%@&ll=%lf,%lf",
							  stop.stopName,
							  [stop.stopName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							  stop.coordinate.latitude,
							  stop.coordinate.longitude
							  ];
			controller.body = body;
			[self presentModalViewController:controller animated:YES];
			[controller release];
		}
	}
}

#pragma mark - MailComposer Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - MFMessageComposeViewController Delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Popover Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[popoverController release];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)dealloc {
	[stop release];
	[infoTableView release];
	[departureTableView release];
	[address release];
	[departures release];
	[refreshButton release];
	[titleView release];
	[super dealloc];
}

@end
