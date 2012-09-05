//
//  Location.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CUConnection.h"

typedef enum {
	LocationTypeText = 0,
	LocationTypeStop,
	LocationTypeCurrentLocation,
	LocationTypeCoordinate
} LocationType;

@interface Location : NSObject <CLLocationManagerDelegate, MKAnnotation> {
	LocationType type;
	CUStop *stop;
	NSString *text;
	CLLocationCoordinate2D coordinate;
	NSOperationQueue *queue;
	void (^handler)(BOOL, NSError*);
}

- (void)resolveWithHandler:(void(^)(BOOL success, NSError *error))handler;

@property (nonatomic) LocationType type;
@property (nonatomic, retain) CUStop *stop;
@property (nonatomic, retain) NSString *text;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) void (^handler)(BOOL, NSError*);

@end
