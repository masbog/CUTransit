//
//  AppDelegate.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CUStop, StopsController, PlannerController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate> {
	StopsController *stopsController;
	PlannerController *plannerController;
}

- (void)showStop:(CUStop*)stop;
- (void)showDirectionsWithStop:(CUStop*)stop isOrigin:(BOOL)isOrigin;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end
