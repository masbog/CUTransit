//
//  RoutesController.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CUConnection.h"

@interface RoutesController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	UITableView *tableView;
	NSArray *routes;
	NSArray *routeGroups;
	int mode;
	CGFloat scrollPositions[3];
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *routes;
@property (nonatomic, retain) NSArray *routeGroups;

@end
