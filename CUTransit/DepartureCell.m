//
//  DepartureCell.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "DepartureCell.h"
#import "StopDatabase.h"


@interface DepartureView : UIView {
	CUDeparture *departure;
	BOOL highlighted;
}

@property (nonatomic, retain) CUDeparture *departure;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

@end

@implementation DepartureView

@synthesize departure, highlighted;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor whiteColor];
		self.contentMode = UIViewContentModeRedraw;
	}
	return self;
}

- (void)drawRect:(CGRect)_rect {
	UIFont *font1 = [UIFont boldSystemFontOfSize:18.0f];
	UIFont *font2 = [UIFont systemFontOfSize:14.0f];
	UIFont *font3 = [UIFont systemFontOfSize:17.0f];
	
	CGContextRef context = UIGraphicsGetCurrentContext();

	// head sign
	if (highlighted) {
		CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
	} else {
		CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
	}
	[departure.headsign drawAtPoint:CGPointMake(10.0f, 2.0f) withFont:font1];
	
	// expected minutes
	if (!highlighted)
		CGContextSetRGBFillColor(context, 0.22f, 0.33f, 0.53f, 1.0f);
	NSString *time = (departure.expectedMinutes == 0) ? @"due" : [NSString stringWithFormat:@"%d %@", departure.expectedMinutes, (departure.expectedMinutes > 1) ? @"mins" : @"min"];
	CGRect rect = CGRectMake(self.frame.size.width-70-10, 11, 70, 21);
	[time drawInRect:rect withFont:font3 lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
	
	// destination stop name
	if (!highlighted)
		CGContextSetRGBFillColor(context, 0.5f, 0.5f, 0.5f, 1.0f);
	CGRect rect2 = CGRectMake(10, 24.0f, 300, 18.0f);
	[[StopDatabase stopNameForStopID:departure.destinationStopID] drawInRect:rect2 withFont:font2 lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentLeft];
}

- (void)setHighlighted:(BOOL)lit {
	if (highlighted != lit) {
		highlighted = lit;
		[self setNeedsDisplay];
	}
}

- (void)setDeparture:(CUDeparture *)newDeparture {
	if (departure != newDeparture) {
		[departure release];
		departure = [newDeparture retain];
		[self setNeedsDisplay];
	}
}

- (void)dealloc {
	[departure release];
	[super dealloc];
}

@end


@implementation DepartureCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		departureView = [[DepartureView alloc] initWithFrame:self.contentView.bounds];
		departureView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:departureView];
	}
	return self;
}

- (void)setDeparture:(CUDeparture *)newDeparture {
	departureView.departure = newDeparture;
}

- (void)dealloc {
	[departureView release];
	[super dealloc];
}

@end
