//
//  RoutesController.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "RoutesController.h"
#import "RouteController.h"
#import "RouteDatabase.h"

@implementation RoutesController

@synthesize tableView, routes, routeGroups;

static UIImage* imageWithColor(UIColor *color) {
	CGRect rect = CGRectMake(0.0f, 0.0f, 43.0f, 43.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

- (id)init {
	if (self = [super init]) {
		self.title = @"Routes";
	}
	return self;
}

- (void)viewDidLoad {
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *date = [NSDate date];
	NSInteger weekday = [[calendar components:NSWeekdayCalendarUnit fromDate:date] weekday];
	[calendar release];
	
	// Segmented control
	NSArray *items = [NSArray arrayWithObjects:@"Weekday", @"Saturday", @"Sunday", nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
	segmentedControl.frame = CGRectMake(0, 0, self.view.frame.size.width, 44.0f);
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	segmentedControl.segmentedControlStyle = 7; // undocumented style
	NSInteger segmentedIndex;
	if (weekday == 1)
		segmentedIndex = 2; // Sunday
	else if (weekday == 7)
		segmentedIndex = 1; // Saturday
	else
		segmentedIndex = 0; // Weekday
	segmentedControl.selectedSegmentIndex = segmentedIndex;
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:segmentedControl];
	[segmentedControl release];
	
	// Table view
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f) style:UITableViewStylePlain];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tableView.dataSource = self;
	tableView.delegate = self;
	[self.view addSubview:tableView];
	[tableView release];
	
	// Load data
	self.routeGroups = [RouteDatabase routeGroups];
	if (weekday == 1)
		self.routes = [routeGroups objectAtIndex:kRouteDatabaseSunday];
	else if (weekday == 7)
		self.routes = [routeGroups objectAtIndex:kRouteDatabaseSaturday];
	else
		self.routes = [routeGroups objectAtIndex:kRouteDatabaseWeekday];
	
	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:YES];
}

- (void)segmentAction:(id)sender {
	UISegmentedControl *segmentedControl = sender;
	NSInteger index = segmentedControl.selectedSegmentIndex;
	scrollPositions[mode] = MAX(tableView.contentOffset.y, 0.0f);
	mode = index;
	if (index == 0)
		self.routes = [routeGroups objectAtIndex:kRouteDatabaseWeekday];
	else if (index == 1)
		self.routes = [routeGroups objectAtIndex:kRouteDatabaseSaturday];
	else if (index == 2)
		self.routes = [routeGroups objectAtIndex:kRouteDatabaseSunday];
	[tableView reloadData];
	[tableView setContentOffset:CGPointMake(0, scrollPositions[mode]) animated:NO];
	[tableView flashScrollIndicators];
}

#pragma mark - DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [routes count];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
	}
	
	CURoute *route = [routes objectAtIndex:indexPath.row];
	cell.textLabel.text = route.routeShortName;
	cell.detailTextLabel.text = route.routeLongName;
	cell.imageView.image = imageWithColor(route.routeColor);
	
	return cell;
}

#pragma mark - Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CURoute *route = [routes objectAtIndex:indexPath.row];
	RouteController *controller = [[RouteController alloc] initWithRoute:route];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}


#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return YES;
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)dealloc {
	[tableView release];
	[routes release];
	[routeGroups release];
	[super dealloc];
}

@end
