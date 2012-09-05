//
//  LegAnnotationView.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "LegAnnotationView.h"
#import "CUConnection.h"

@implementation LegAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	if (self != nil) {
		CGRect frame = self.frame;
		frame.size = CGSizeMake(35.0f, 32.0f);
		self.frame = frame;
		self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"callout_left"]];
		self.centerOffset = CGPointMake(-35.0/2, -32.0/2);
		self.calloutOffset = CGPointMake(-6.0f, 0.0f);
	}
	return self;
}

- (void)setAnnotation:(id <MKAnnotation>)annotation {
	[super setAnnotation:annotation];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	CULeg *leg = self.annotation;
	UIImage *img = [UIImage imageNamed:leg.type == CULegTypeWalk ? @"callout_walk" : @"callout_bus"];
	[img drawAtPoint:CGPointMake(4, 4)];
}

@end
