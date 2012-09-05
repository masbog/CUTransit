//
//  StopController.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CUConnection.h"

@class TitleView;

@interface StopController : UITableViewController {
	CUStop *stop;
	NSArray *departures;
	
	TitleView *titleView;
	UIBarButtonItem *refreshButton;
	
	BOOL isLoading;
	BOOL looksAhead;
	NSTimer *timer;
	int nRepeats;
}

- (id)initWithStop:(CUStop*)s;

@property (nonatomic, retain) CUStop *stop;
@property (nonatomic, retain) NSArray *departures;

@end
