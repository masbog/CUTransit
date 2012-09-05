//
//  CULeg.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
	CULegTypeWalk,
	CULegTypeService,
	CULegTypeUnknown
} CULegType;

@class CUWalk;

@interface CULeg : NSObject <MKAnnotation> {
	CULegType type;
	CUWalk *walk;
	NSArray *services;
	
	// internal use, for displaying in table
	NSString *text;
	CGFloat rowHeight;
}

- (id)initWithDictionary:(id)dic;
- (CLLocationCoordinate2D)beginCoordinate;
- (CLLocationCoordinate2D)endCoordinate;
- (CLLocationCoordinate2D)coordinate;

@property (nonatomic) CULegType type;
@property (nonatomic, retain) CUWalk *walk;
@property (nonatomic, retain) NSArray *services;
@property (nonatomic, retain) NSString *text;
@property (nonatomic) CGFloat rowHeight;

@end
