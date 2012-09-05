//
//  CUShape.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CUShape : NSObject <MKOverlay> {
	NSArray *points;
	MKMapRect boundingMapRect;
	
	BOOL highlighted;
	BOOL hidden;
}

- (id)initWithObject:(id)obj;
- (id)initWithCoordinate:(CLLocationCoordinate2D)c1 andCoordinate:(CLLocationCoordinate2D)c2;

@property (nonatomic, retain) NSArray *points;
@property (nonatomic) MKMapRect boundingMapRect;
@property (nonatomic) BOOL highlighted;
@property (nonatomic) BOOL hidden;

@end
