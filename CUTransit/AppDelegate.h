//
//  AppDelegate.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CUStop, PlannerController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate> {
	PlannerController *plannerController;
}

- (void)showDirectionsWithStop:(CUStop*)stop isOrigin:(BOOL)isOrigin;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end
