//
//  StopInfoController.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "StopInfoController.h"
#import "StopController.h"
#import "AppDelegate.h"
#import "BookmarkDatabase.h"
#import <QuartzCore/QuartzCore.h>

#define TITLE_COLOR [UIColor colorWithRed:81/255.0f green:102/255.0f blue:145/255.0f alpha:1.0f]


@interface StopThumbnailView : UIView

@end

@implementation StopThumbnailView

- (id)initWithFrame:(CGRect)frame stop:(CUStop*)stop {
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		
		MKCoordinateRegion region;
		region.center = stop.coordinate;
		region.span.latitudeDelta = 0.005;
		region.span.longitudeDelta = 0.005;
		
		MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(-100, -100 + 6, frame.size.width+200, frame.size.height+200)];
		[mapView setRegion:region animated:NO];
		[self addSubview:mapView];
		[mapView release];
		
		UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smallpin"]];
		imgView.center = CGPointMake(CGRectGetMidX(self.bounds)+5, CGRectGetMidY(self.bounds)-8 + 6);
		[self addSubview:imgView];
		[imgView release];
		
		self.layer.cornerRadius = 5.0f;
		self.layer.masksToBounds = YES;
		self.layer.borderWidth = 1.0f;
		self.layer.borderColor = [[UIColor colorWithRed:131/255.0 green:131/255.0 blue:131/255.0 alpha:1.0f] CGColor];
	}
	return self;
}

@end


@implementation StopInfoController

@synthesize stop;

- (id)initWithStop:(CUStop*)s {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		self.title = @"Info";
		self.stop = s;
	}
	return self;
}

- (void)updateBookmarkButton {
	if ([BookmarkDatabase hasStop:stop]) {
		[bookmarkButton setTitle:@"Remove from Bookmarks" forState:UIControlStateNormal];
	} else {
		[bookmarkButton setTitle:@"Add to Bookmarks" forState:UIControlStateNormal];
	}
}

#pragma mark - Actions

- (void)shareAction:(id)sender {
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

- (void)bookmarkAction:(id)sender {
	if (![BookmarkDatabase hasStop:stop]) {
		[BookmarkDatabase addStop:stop];
	} else {
		[BookmarkDatabase removeStop:stop];
	}
	[self updateBookmarkButton];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
		return 1;
	if (section == 1)
		return 2;
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];
		cell.textLabel.textColor = TITLE_COLOR;
	}
	
	NSUInteger row = indexPath.row;
	
	if (indexPath.section == 0) {
		if (row == 0)
			cell.textLabel.text = @"Departures";
	} else if (indexPath.section == 1) {
		if (row == 0)
			cell.textLabel.text = @"Directions To Here";
		else if (row == 1)
			cell.textLabel.text = @"Directions From Here";
	}
	
	return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section != 0)
		return 0.0f;
	return 94.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section != 0)
		return nil;
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 94.0f)];
	

	StopThumbnailView *thumbnail = [[StopThumbnailView alloc] initWithFrame:CGRectMake(18, 14, 64, 64) stop:stop];
	[self.view addSubview:thumbnail];
	[thumbnail release];
	
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(96, 10, 320-96-20, 73)];
	label.lineBreakMode = UILineBreakModeWordWrap;
	label.numberOfLines = 0;
	label.font = [UIFont boldSystemFontOfSize:18.0f];
	label.text = stop.stopName;
	label.shadowColor = [UIColor whiteColor];
	label.shadowOffset = CGSizeMake(0.0f, 1.0f);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	[label release];
	
	return [view autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section != 1)
		return 0.0f;
	return 59.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			StopController *controller = [[StopController alloc] initWithStop:stop];
			[self.navigationController pushViewController:controller animated:YES];
			[controller release];
		}
	} else if (indexPath.section == 1) {
		AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate showDirectionsWithStop:stop isOrigin:indexPath.row == 1];
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

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)dealloc {
	[stop release];
	[super dealloc];
}

@end
