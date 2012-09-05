//
//  StepDescriptionView.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "StepDescriptionView.h"

#define INF 400.0f

@implementation StepDescriptionView

@synthesize text, text2, stopButton, showsStopButton, delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		// we draw background color instead because the view can appear as if it's resized.
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGFloat w = self.bounds.size.width;
	static const CGFloat padW = 12.0f;
	static const CGFloat padH = 6.0f;
	
	UIFont *font = [UIFont boldSystemFontOfSize:14.0f];
	CGSize size = [text sizeWithFont:font forWidth:w-padW*2 lineBreakMode:UILineBreakModeWordWrap];
	
	UIFont *font2 = [UIFont systemFontOfSize:14.0f];
	CGSize size2 = [text2 sizeWithFont:font2 constrainedToSize:CGSizeMake(w-padW*2, INF)];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// background
	CGContextSetRGBFillColor(context, 113/255.0, 134/255.0, 164/255.0, 0.8f);
	CGContextFillRect(context, CGRectMake(0, 0, w, padH+size.height+size2.height+padH));
	
	// shadow
	CGContextSetRGBFillColor(context, 65/255.0, 74/255.0, 86/255.0, 1.0f);
	[text drawInRect:CGRectMake(padW, padH-1.0f, w-padW*2, INF) withFont:font lineBreakMode:UILineBreakModeWordWrap];
	[text2 drawInRect:CGRectMake(padW, padH+size.height-1.0f, w-padW*2, INF) withFont:font2 lineBreakMode:UILineBreakModeWordWrap];
	
	// text
	CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
	[text drawInRect:CGRectMake(padW, padH, w-padW*2, INF) withFont:font lineBreakMode:UILineBreakModeWordWrap];
	[text2 drawInRect:CGRectMake(padW, padH+size.height, w-padW*2, INF) withFont:font2 lineBreakMode:UILineBreakModeWordWrap];
	
	// bottom border
	CGContextSetRGBFillColor(context, 57/255.0, 68/255.0, 82/255.0, 1.0f);
	CGContextFillRect(context, CGRectMake(0, padH+size.height+size2.height+padH-1.0f, w, 1.0f));
}

- (void)setText:(NSString *)newText {
	if (text != newText) {
		[text release];
		text = [newText retain];
		[self setNeedsDisplay];
	}
}

- (void)setText2:(NSString *)newText2 {
	if (text2 != newText2) {
		[text2 release];
		text2 = [newText2 retain];
		[self setNeedsDisplay];
	}
}

- (void)setShowsStopButton:(BOOL)newShowsStopButton {
	if (showsStopButton != newShowsStopButton) {
		showsStopButton = newShowsStopButton;
		[self setNeedsDisplay];
		
		if (showsStopButton) {
			if (!stopButton) {
				self.stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
				stopButton.frame = CGRectMake(self.bounds.size.width-12.0f-33.0f, 16.0f, 32.0f, 33.0f);
				stopButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
				[stopButton setBackgroundImage:[UIImage imageNamed:@"flat_button"] forState:UIControlStateNormal];
				[stopButton setBackgroundImage:[UIImage imageNamed:@"flat_button_pressed"] forState:UIControlStateHighlighted];
				[stopButton setImage:[UIImage imageNamed:@"flat_button_clock"] forState:UIControlStateNormal];
				[stopButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:stopButton];
			}
		} else {
			if (stopButton) {
				[stopButton removeFromSuperview];
				self.stopButton = nil;
			}
		}
	}
}

- (void)buttonClicked:(id)sender {
	if ([delegate respondsToSelector:@selector(stepDescriptionViewDidClickStopButton:)])
		[delegate performSelector:@selector(stepDescriptionViewDidClickStopButton:) withObject:self];
}

- (void)dealloc {
	[text release];
	[text2 release];
	[stopButton release];
	[super dealloc];
}

@end
