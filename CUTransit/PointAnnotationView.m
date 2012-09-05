//
//  PointAnnotationView.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "PointAnnotationView.h"

#define DIAMETER 70.0f

@implementation PointAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil) {
        CGRect frame = self.frame;
        frame.size = CGSizeMake(80.0f, 80.0f);
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        //self.centerOffset = CGPointMake(30.0, 42.0);
		
		self.enabled = NO;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.superview sendSubviewToBack:self];
}

- (void)setAnnotation:(id <MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CUPoint *point = (CUPoint*)self.annotation;
    if (point) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetRGBFillColor(context, 28/255.0, 102/255.0, 234/255.0, 66/255.0);
		CGContextFillEllipseInRect(context, CGRectMake(5, 5, DIAMETER, DIAMETER));
		CGContextSetLineWidth(context, 2);
		CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.7);
		CGContextStrokeEllipseInRect(context, CGRectMake(5, 5, DIAMETER, DIAMETER));
    }
}

@end
