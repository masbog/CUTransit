//
//  SecondViewController.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CUConnection.h"
#import "LocationController.h"

@class Location, LocationTextField;

@interface PlannerController : UIViewController <UITextFieldDelegate, LocationControllerDelegate> {
	IBOutlet LocationTextField *startTextField;
	IBOutlet LocationTextField *endTextField;
	IBOutlet UITableView *resultsTableView;
	UIButton *swapButton;
	IBOutlet UIView *searchCancelView;
	UIBarButtonItem *routeButton;
	IBOutlet UITableView *itinerariesTableView;
	IBOutlet UIView *loadingView;
	IBOutlet UIActivityIndicatorView *spinView;
	
	NSArray *searchResults;
	LocationTextField *selectedTextField;
	Location *originLocation;
	Location *destinationLocation;
	Location *selectedLocation;
	
	BOOL disableAnimation;
	
	NSArray *itineraries;
	
	BOOL showsCurrentLocationResult;
	BOOL disableSearchStringChanged;
	int searchTimestamp;
}

- (IBAction)cancelSearch:(id)sender;
- (IBAction)searchStringChanged:(id)sender;
- (void)showDirectionsWithStop:(CUStop*)stop isOrigin:(BOOL)isOrigin;
- (void)showDirectionsWithDirectionRequests:(MKDirectionsRequest*)request;

@property (nonatomic, retain) LocationTextField *startTextField;
@property (nonatomic, retain) LocationTextField *endTextField;
@property (nonatomic, retain) UITableView *resultsTableView;
@property (nonatomic, retain) UIButton *swapButton;
@property (nonatomic, retain) UIView *searchCancelView;
@property (nonatomic, retain) UIBarButtonItem *routeButton;
@property (nonatomic, retain) UITableView *itinerariesTableView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UIActivityIndicatorView *spinView;

@property (nonatomic, retain) NSArray *searchResults;
@property (nonatomic, retain) Location *originLocation;
@property (nonatomic, retain) Location *destinationLocation;
@property (nonatomic, retain) NSArray *itineraries;

@end
