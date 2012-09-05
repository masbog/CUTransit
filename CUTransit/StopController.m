//
//  StopController.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "StopController.h"
#import "common.h"
#import "DepartureController.h"
#import "TitleView.h"
#import "DepartureCell.h"

#define MAX_REPEATS 10
#define REPEAT_INTERVAL 55

@implementation StopController

@synthesize stop, departures;

- (id)initWithStop:(CUStop*)s {
	if (self = [super init]) {
		self.stop = s;
		
		[self setupTitleView];
		[self setupRefreshButton];
		titleView.text = stop.stopName;
		
		[self refresh];
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
	refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
	refreshButton.style = UIBarButtonItemStyleBordered;
	self.navigationItem.rightBarButtonItem = refreshButton;
	[refreshButton release];
}

- (void)viewDidDisappear:(BOOL)animated {
	if (self.parentViewController == nil) { // the view controller has been popped from the stack
		[timer invalidate];
		timer = nil;
	}
}

- (void)resetTimer {
	[timer invalidate];
	nRepeats = MAX_REPEATS;
	timer = [NSTimer scheduledTimerWithTimeInterval:REPEAT_INTERVAL target:self selector:@selector(scheduledRefresh:) userInfo:nil repeats:YES];
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
				 
				 //self.tableView.allowsSelection = [departures count] > 0;
				 [self.tableView reloadData];
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

#pragma mark - DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		if ([departures count] == 0 && !isLoading)
			return 4;
		return [departures count];
	}
	if (section == 1)
		return (looksAhead || isLoading) ? 0 : 1;
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
	
	return nil;
}

#pragma mark - Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)dealloc {
	[stop release];
	[departures release];
	[super dealloc];
}

@end
