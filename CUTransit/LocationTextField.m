//
//  LocationTextField.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "LocationTextField.h"
#import "Location.h"

#define CURRENT_LOCATION_COLOR [UIColor colorWithRed:41/255.0f green:87/255.0f blue:1.0f alpha:1.0f]

@implementation LocationTextField

@synthesize label, bookmarkButton, location;

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
		label.font = [UIFont systemFontOfSize:14.0f];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor grayColor];
		label.textAlignment = UITextAlignmentRight;
		self.leftView = label;
		self.leftViewMode = UITextFieldViewModeAlways;
		[label release];
		
		self.bookmarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		bookmarkButton.frame = CGRectMake(0, 0, 40, 29);
		[bookmarkButton setImage:[UIImage imageNamed:@"bookmarks"] forState:UIControlStateNormal];
		[bookmarkButton setImage:[UIImage imageNamed:@"bookmarks_pressed"] forState:UIControlStateHighlighted];
		self.rightView = bookmarkButton;
		self.rightViewMode = UITextFieldViewModeWhileEditing;
	}
	return self;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
	return CGRectMake(bounds.size.width-40.0f-1.0f, 2.0f, 40.0f, 29.0f);
}

- (void)setLocation:(Location*)newLocation {
	if (location != newLocation) {
		[location release];
		location = [newLocation retain];
	}
	
	self.text = location.text;
	self.textColor = (location.type == LocationTypeCurrentLocation) ? CURRENT_LOCATION_COLOR : [UIColor blackColor];
}

- (void)dealloc {
	[label release];
	[bookmarkButton release];
	[location release];
	[super dealloc];
}

@end
