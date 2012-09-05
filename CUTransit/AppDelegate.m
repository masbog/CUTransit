//
//  AppDelegate.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "AppDelegate.h"
#import "StopsController.h"
#import "PlannerController.h"
#import "RoutesController.h"
#import "BookmarksController.h"
#import "CUConnection.h"


@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (void)dealloc {
	[_window release];
	[_tabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

	// Stops tab
	UIViewController *stopsController = [[[StopsController alloc] initWithNibName:@"StopsController" bundle:nil] autorelease];
	UINavigationController *stopsNav = [[[UINavigationController alloc] initWithRootViewController:stopsController] autorelease];
	stopsNav.tabBarItem.image = [UIImage imageNamed:@"clock"];
	
	// Trip Planner tab
	plannerController = [[[PlannerController alloc] initWithNibName:@"PlannerController" bundle:nil] autorelease];
	UINavigationController *plannerNav = [[[UINavigationController alloc] initWithRootViewController:plannerController] autorelease];
	plannerNav.tabBarItem.image = [UIImage imageNamed:@"map"];

	// Bookmarks tab
	UIViewController *bookmarksController = [[[BookmarksController alloc] init] autorelease];
	UINavigationController *bookmarksNav = [[[UINavigationController alloc] initWithRootViewController:bookmarksController] autorelease];
	 
	// Routes tab
	UIViewController *routesController = [[[RoutesController alloc] init] autorelease];
	UINavigationController *routesNav = [[[UINavigationController alloc] initWithRootViewController:routesController] autorelease];
	routesNav.tabBarItem.image = [UIImage imageNamed:@"bus"];
	
	// tab bar
	self.tabBarController = [[[UITabBarController alloc] init] autorelease];
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:stopsNav, plannerNav, bookmarksNav, routesNav, nil];
	
	self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
	
    return YES;
}

- (void)showDirectionsWithStop:(CUStop*)stop isOrigin:(BOOL)isOrigin {
	[plannerController showDirectionsWithStop:stop isOrigin:isOrigin];
	self.tabBarController.selectedIndex = 1;
}

@end
