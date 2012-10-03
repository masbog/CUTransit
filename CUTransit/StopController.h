//
//  StopController.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "CUConnection.h"

@class TitleView;

@interface StopController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIPopoverControllerDelegate> {
	CUStop *stop;
	
	UITableView *infoTableView;
	UITableView *departureTableView;
	UIButton *bookmarkButton;
	
	BOOL showsDepartureFirst;
	NSString *address;
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
@property (nonatomic, retain) UITableView *infoTableView;
@property (nonatomic, retain) UITableView *departureTableView;
@property (nonatomic) BOOL showsDepartureFirst;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSArray *departures;
@property (nonatomic, retain) UIBarButtonItem *refreshButton;

@end
