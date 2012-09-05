//
//  RouteController.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CUConnection.h"

@interface RouteController : UIViewController <MKMapViewDelegate> {
	CURoute *route;
	UIWebView *mapWebView;
	UIWebView *scheduleWebView;
}

- (id)initWithRoute:(CURoute*)r;

@property (nonatomic, retain) CURoute *route;
@property (nonatomic, retain) UIWebView *mapWebView;
@property (nonatomic, retain) UIWebView *scheduleWebView;

@end
