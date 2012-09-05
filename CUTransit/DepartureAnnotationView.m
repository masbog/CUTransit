//
//  DepartureAnnotationView.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "DepartureAnnotationView.h"
#import "CUConnection.h"

@interface HaloView : UIImageView {
	NSTimer *timer;
}

- (void)stopAnimatingHalo;

@end

@implementation HaloView

- (id)init {
	if (self = [super initWithImage:[UIImage imageNamed:@"halo"]]) {
		timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(animate:) userInfo:nil repeats:YES];
	}
	return self;
}

- (void)animate:(id)userInfo {
	self.transform = CGAffineTransformMakeScale(0.2, 0.2);
	self.alpha = 1.0f;
	[UIView animateWithDuration:1.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.transform = CGAffineTransformIdentity;
		self.alpha = 0.0f;
	} completion:NULL];
}

- (void)stopAnimatingHalo {
	[timer invalidate];
}

@end


@implementation DepartureAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	if (self != nil) {
		CGRect frame = self.frame;
		frame.size = CGSizeMake(21.0f, 23.0f);
		self.frame = frame;
		self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bus_dot"]];
		self.calloutOffset = CGPointMake(0.0f, 4.0f);
		
		halo = [[HaloView alloc] init];
		halo.frame = CGRectMake(0, 0, 100, 100);
		halo.center = CGPointMake(21.0f/2, 23.0f/2);
		halo.alpha = 0;
		[self addSubview:halo];
	}
	return self;
}

- (void)dealloc {
	[halo stopAnimatingHalo];
	[halo release];
	[super dealloc];
}

@end
