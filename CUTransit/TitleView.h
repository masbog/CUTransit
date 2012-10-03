//
//  TitleView.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>

// A view for displaying two-line title.
// Use text2 to display the second line in an entire bold text.
// Use text2s to display the second line alternating between bold text and plain text.
// e.g. if you set text2s = [@"1", @"2", @"3", @"4"], it will show
// <b>1</b>2<b>3</b>4.
@interface TitleView : UIView {
	NSString *text;
	NSString *text2;
	NSArray *text2s;
	int mode;
}

- (void)setUpdated;

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *text2;
@property (nonatomic, retain) NSArray *text2s;

@end
