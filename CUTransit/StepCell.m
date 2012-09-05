//
//  StepCell.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "StepCell.h"
#import <CoreText/CoreText.h>


@implementation StepView

@synthesize text, type, highlighted;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor whiteColor];
		self.contentMode = UIViewContentModeRedraw;
	}
	return self;
}

- (void)setHighlighted:(BOOL)lit {
	if (highlighted != lit) {
		highlighted = lit;
		[self setNeedsDisplay];
	}
}

+ (NSAttributedString*)attributedStringForText:(NSString*)text highlighted:(BOOL)highlighted {
	UIColor *color1, *color2, *color3;
	
	if (!highlighted) {
		color1 = [UIColor blackColor];
		color2 = [UIColor colorWithRed:56/255.0 green:84/255.0 blue:135/255.0 alpha:1.0f];
		color3 = [UIColor colorWithWhite:0.5f alpha:1.0f];
	} else {
		color1 = color2 = color3 = [UIColor whiteColor];
	}
	
	//TODO: use Helvetica Neue on retina display
	CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 14.0, NULL);
	NSDictionary *attrs = [[NSDictionary alloc] initWithObjectsAndKeys:
						   (id)[color1 CGColor], kCTForegroundColorAttributeName,
						   font, kCTFontAttributeName,
						   nil];
	CFRelease(font);
	
	CTFontRef font2 = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 14.0, NULL); 
	NSDictionary *attrs2 = [[NSDictionary alloc] initWithObjectsAndKeys:
							(id)[color1 CGColor], kCTForegroundColorAttributeName,
							font2, kCTFontAttributeName,
							nil];
	CFRelease(font2);
	
	CTFontRef font3 = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 14.0, NULL); 
	NSDictionary *attrs3 = [[NSDictionary alloc] initWithObjectsAndKeys:
							(id)[color2 CGColor], kCTForegroundColorAttributeName,
							font3, kCTFontAttributeName,
							nil];
	CFRelease(font3);
	
	CTFontRef font4 = CTFontCreateWithName(CFSTR("Helvetica"), 14.0, NULL); 
	NSDictionary *attrs4 = [[NSDictionary alloc] initWithObjectsAndKeys:
							(id)[color3 CGColor], kCTForegroundColorAttributeName,
							font4, kCTFontAttributeName,
							nil];
	CFRelease(font4);
	
	NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@""];
	
	NSArray *chunks = [text componentsSeparatedByString:@"|"];
	for (NSString *chunk in chunks) {
		NSDictionary *d;
		if ([chunk hasPrefix:@"@"]) {
			d = attrs2;
			chunk = [chunk substringFromIndex:1];
		} else if ([chunk hasPrefix:@"^"]) {
			d = attrs3;
			chunk = [chunk substringFromIndex:1];
		} else if ([chunk hasPrefix:@"$"]) {
			d = attrs4;
			chunk = [chunk substringFromIndex:1];
		} else {
			d = attrs;
		}
		
		NSAttributedString *tmp = [[NSAttributedString alloc] initWithString:chunk attributes:d];
		[attrString appendAttributedString:tmp];
		[tmp release];
	}
	
	[attrs release];
	[attrs2 release];
	[attrs3 release];
	[attrs4 release];
	
	return [attrString autorelease];
}

+ (CGFloat)heightForText:(NSString*)text {
	CGFloat w = 320.0f; //TODO: remove hard coding
	
	CGRect bounds = CGRectMake(0, 0, w-20.0-30, 1000);
	CGPathRef path = CGPathCreateWithRect(bounds, NULL);
	
	NSAttributedString *attrString = [StepView attributedStringForText:text highlighted:NO];
	
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
	
	CFArrayRef lines = CTFrameGetLines(frame);
	CFIndex nLines = CFArrayGetCount(lines);
	
	CFRelease(frame);
	CFRelease(framesetter);
	CGPathRelease(path);
	
	return nLines*18.0 + 14.0;
}

- (void)drawRect:(CGRect)rect {
	UIImage *img = [UIImage imageNamed:type == CULegTypeWalk ? @"walking_icon" : @"bus_icon"];
	[img drawAtPoint:CGPointMake(12, 8)];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat w = self.bounds.size.width;
	
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextScaleCTM(context, 1, -1);
	
	CGRect bounds = CGRectMake(10.0+30, 0, w-20.0-30, 1000);
	CGPathRef path = CGPathCreateWithRect(bounds, NULL);
	
	NSAttributedString *attrString = [StepView attributedStringForText:text highlighted:highlighted];
	
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
	
	CFArrayRef lines = CTFrameGetLines(frame);
	for (CFIndex i=0; i<CFArrayGetCount(lines); i++) {
		CGContextSetTextPosition(context, 10.0+30, -20.0-18.0*i);
		CTLineRef line = CFArrayGetValueAtIndex(lines, i);
		CTLineDraw(line, context);
	}
	
	CFRelease(frame);
	CFRelease(framesetter);
	CGPathRelease(path);
}

- (void)setText:(NSString *)newText {
	if (text != newText) {
		[text release];
		text = [newText retain];
		[self setNeedsDisplay];
	}
}

- (void)setType:(CULegType)newType {
	if (type != newType) {
		type = newType;
		[self setNeedsDisplay];
	}
}

- (void)dealloc {
	[text release];
	[super dealloc];
}

@end


#pragma mark -


@implementation StepCell

@synthesize stepView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.stepView = [[StepView alloc] initWithFrame:self.contentView.bounds];
		stepView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:stepView];
		[stepView release];
	}
	return self;
}

+ (CGFloat)heightForText:(NSString*)text {
	return [StepView heightForText:text];
}

- (void)dealloc {
	[stepView release];
	[super dealloc];
}

@end
