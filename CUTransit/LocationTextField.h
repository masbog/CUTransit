//
//  LocationTextField.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Location;

@interface LocationTextField : UITextField {
	UILabel *label;
	UIButton *bookmarkButton;
	Location *location;
}

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIButton *bookmarkButton;
@property (nonatomic, retain) Location *location;

@end
