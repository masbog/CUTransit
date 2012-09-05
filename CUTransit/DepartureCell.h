//
//  DepartureCell.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CUConnection.h"

@class DepartureView;

@interface DepartureCell : UITableViewCell {
	DepartureView *departureView;
}

- (void)setDeparture:(CUDeparture *)newDeparture;

@end
