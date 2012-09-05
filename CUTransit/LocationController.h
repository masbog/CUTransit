//
//  BookmarkController.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CUConnection.h"

@class Location;
@protocol LocationControllerDelegate;

@interface LocationController : UIViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate> {
	id<LocationControllerDelegate> delegate;
	UITableView *bookmarksTableView;
	UITableView *stopsTableView;
	NSMutableArray *bookmarkedStops;
	NSMutableArray *stopGroups;
	NSMutableArray *stopLetters;
	MKMapView *mapView;
	Location *location;
	BOOL allowsCoordinateSelection;
	int mode;
}

@property (nonatomic, assign) id<LocationControllerDelegate> delegate;
@property (nonatomic, retain) UITableView *bookmarksTableView;
@property (nonatomic, retain) UITableView *stopsTableView;
@property (nonatomic, retain) NSMutableArray *bookmarkedStops;
@property (nonatomic, retain) NSMutableArray *stopGroups;
@property (nonatomic, retain) NSMutableArray *stopLetters;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) Location *location;
@property (nonatomic) BOOL allowsCoordinateSelection;

@end


@protocol LocationControllerDelegate <NSObject>

- (void)locationController:(LocationController*)controller didSelectLocation:(Location*)location;

@end