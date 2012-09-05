//
//  StepCell.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CUConnection.h"

@interface StepView : UIView {
	NSString *text;
	CULegType type;
	BOOL highlighted;
}

+ (CGFloat)heightForText:(NSString*)text;

@property (nonatomic, retain) NSString *text;
@property (nonatomic) CULegType type;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

@end


@interface StepCell : UITableViewCell {
	StepView *stepView;
}

+ (CGFloat)heightForText:(NSString*)text;

@property (nonatomic, retain) StepView *stepView;

@end
