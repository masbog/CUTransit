//
//  TitleView.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "TitleView.h"

@implementation TitleView

@synthesize text, text2, text2s;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGFloat w = self.bounds.size.width;
	CGFloat y = 24.0f;
	UIColor *fontColor = [UIColor whiteColor];
	UIColor *shadowColor = [UIColor darkGrayColor];
	CGFloat shadowOffsetY = -1.0f;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		fontColor = [UIColor colorWithRed:113/255.0f green:120/255.0f blue:128/255.0f alpha:1.0f];
		shadowColor = [UIColor colorWithRed:230/255.0f green:231/255.0f blue:235/255.0f alpha:1.0f];
		shadowOffsetY = 1.0f;
	}
	
	{
		CGFloat minFontSize = 12.0f;
		CGFloat actualFontSize;
		UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
		CGSize size = [text sizeWithFont:font minFontSize:minFontSize actualFontSize:&actualFontSize forWidth:w lineBreakMode:UILineBreakModeTailTruncation];
		UIFont *actualFont = [UIFont boldSystemFontOfSize:actualFontSize];
		
		[shadowColor setFill];
		[text drawAtPoint:CGPointMake((w - size.width)/2, 3 + shadowOffsetY) forWidth:size.width withFont:actualFont lineBreakMode:UILineBreakModeTailTruncation];
		[fontColor setFill];
		[text drawAtPoint:CGPointMake((w - size.width)/2, 3) forWidth:size.width withFont:actualFont lineBreakMode:UILineBreakModeTailTruncation];
	}
	
	if (mode == 0) {
		UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
		CGSize size = [text2 sizeWithFont:font];
		
		[shadowColor setFill];
		[text2 drawAtPoint:CGPointMake((w - size.width)/2, y + shadowOffsetY) withFont:font];
		[fontColor setFill];
		[text2 drawAtPoint:CGPointMake((w - size.width)/2, y) withFont:font];
	} else if (mode == 1) {
		UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
		UIFont *font2 = [UIFont systemFontOfSize:12.0f];
		
		NSUInteger n = [text2s count];
		CGFloat widths[n];
		CGFloat totalWidth = 0.0f;
		for (NSUInteger i=0; i<n; ++i) {
			UIFont *_font = (i%2 == 0) ? font : font2;
			widths[i] = [[text2s objectAtIndex:i] sizeWithFont:_font].width;
			totalWidth += widths[i];
		}
		
		CGFloat x = (w - totalWidth) / 2;
		for (NSUInteger i=0; i<n; ++i) {
			UIFont *_font = (i%2 == 0) ? font : font2;
			[shadowColor setFill];
			[[text2s objectAtIndex:i] drawAtPoint:CGPointMake(x, y + shadowOffsetY) withFont:_font];
			[fontColor setFill];
			[[text2s objectAtIndex:i] drawAtPoint:CGPointMake(x, y) withFont:_font];
			x += widths[i];
		}
	}
}

- (void)setText:(NSString *)newText {
	if (text != newText) {
		[text release];
		text = [newText retain];
		[self setNeedsDisplay];
	}
}

- (void)setText2:(NSString *)newText2 {
	if (text2 != newText2 || mode != 0) {
		if (text2 != newText2) {
			[text2 release];
			text2 = [newText2 retain];
		}
		mode = 0;
		[self setNeedsDisplay];
	}
}

- (void)setUpdated {
	NSDate *date = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"h:mm "];
	NSString *time = [dateFormatter stringFromDate:date];
	
	[dateFormatter setDateFormat:@"a"];
	NSString *ampm = [dateFormatter stringFromDate:date];
	
	self.text2s = [NSArray arrayWithObjects:@"Updated ", time, ampm, nil];
	
	[dateFormatter release];
	
	mode = 1;
	[self setNeedsDisplay];
}

- (void)dealloc {
	[text release];
	[text2 release];
	[super dealloc];
}

@end
