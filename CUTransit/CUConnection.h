//
//  CUConnection.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CUDeparture.h"
#import "CUItinerary.h"
#import "CULeg.h"
#import "CUPoint.h"
#import "CUError.h"
#import "CURoute.h"
#import "CUService.h"
#import "CUStop.h"
#import "CUShape.h"
#import "CUTrip.h"
#import "CUWalk.h"

typedef void (^CUHandler)(id data, CUError *error);

@interface CUConnection : NSObject {
	NSOperationQueue *queue;
	int pendingRequestCount;
}

+ (CUConnection*)sharedConnection;
- (void)requestDeparturesByStopID:(NSString*)stopID lookAhead:(BOOL)lookAhead handler:(CUHandler)handler;
//- (void)requestStopsUsingHandler:(CUHandler)handler;
- (void)requestStopsBySearch:(NSString*)query handler:(CUHandler)handler;
- (void)requestShapeByShapeID:(NSString*)shapeID handler:(CUHandler)handler;
- (void)requestShapeBetweenStopID:(NSString*)beginStopID andStopID:(NSString*)endStopID shapeID:(NSString*)shapeID handler:(CUHandler)handler;
- (void)requestPlannedTripsByOriginStopID:(NSString*)originStopID destinationStopID:(NSString*)destStopID handler:(CUHandler)handler;
- (void)requestPlannedTripsByOriginCoordinate:(CLLocationCoordinate2D)originCoordinate destinationCoordinate:(CLLocationCoordinate2D)destCoordinate handler:(CUHandler)handler;

@end
