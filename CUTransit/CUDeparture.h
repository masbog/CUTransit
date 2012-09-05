//
//  CUDeparture.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class CUTrip;

@interface CUDeparture : NSObject <MKAnnotation> {
	NSString *headsign;
	int expectedMinutes;
	CLLocationCoordinate2D coordinate;
	CUTrip *trip;
	NSString *vehicleID;
	NSString *expected;
	NSString *destinationStopID;
}

- (id)initWithDictionary:(id)dic;

@property (nonatomic, retain) NSString *headsign;
@property (nonatomic, readonly) int expectedMinutes;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) CUTrip *trip;
@property (nonatomic, retain) NSString *vehicleID;
@property (nonatomic, retain) NSString *expected;
@property (nonatomic, retain) NSString *destinationStopID;

@end
