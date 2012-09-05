//
//  RouteController.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "RouteController.h"
#import "ShapeView.h"

@implementation RouteController

@synthesize route, mapWebView, scheduleWebView;

- (id)initWithRoute:(CURoute*)r {
	if (self = [super init]) {
		self.route = r;
		self.title = [NSString stringWithFormat:@"%@ %@", route.routeShortName, route.routeLongName];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSArray *items = [NSArray arrayWithObjects:@"Map", @"Schedule", nil];
	
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
	segmentedControl.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	segmentedControl.segmentedControlStyle = 7; // undocumented style
	segmentedControl.selectedSegmentIndex = 0;
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:segmentedControl];
	[segmentedControl release];
	
	if (mapWebView == nil) {
		self.mapWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f)];
		mapWebView.scalesPageToFit = YES;
		mapWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.view addSubview:mapWebView];
		[mapWebView release];
		
		NSURL *url = [[NSBundle mainBundle] URLForResource:route.map withExtension:@"pdf"];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		[mapWebView loadRequest:request];
	}
}

- (void)segmentAction:(id)sender {
	UISegmentedControl *segmentedControl = sender;
	
	NSInteger index = segmentedControl.selectedSegmentIndex;
	if (index == 0) {
		[self.view bringSubviewToFront:mapWebView];
	} else if (index == 1) {
		if (scheduleWebView == nil) {
			self.scheduleWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f)];
			scheduleWebView.scalesPageToFit = YES;
			scheduleWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			[self.view addSubview:scheduleWebView];
			[scheduleWebView release];
			
			NSURL *url = [[NSBundle mainBundle] URLForResource:route.schedule withExtension:@"pdf"];
			NSURLRequest *request = [NSURLRequest requestWithURL:url];
			[scheduleWebView loadRequest:request];
		}
		[self.view bringSubviewToFront:scheduleWebView];
	}
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)dealloc {
	[route release];
	[mapWebView release];
	[scheduleWebView release];
	[super dealloc];
}

@end