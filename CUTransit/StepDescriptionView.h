//
//  StepDescriptionView.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StepDescriptionView : UIView {
	NSString *text;
	NSString *text2;
	UIButton *stopButton;
	BOOL showsStopButton;
	id delegate;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *text2;
@property (nonatomic, retain) UIButton *stopButton;
@property (nonatomic) BOOL showsStopButton;
@property (nonatomic, assign) id delegate;

@end
