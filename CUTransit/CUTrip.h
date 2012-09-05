//
//  CUTrip.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CUTrip : NSObject {
	NSString *routeID;
	NSString *shapeID;
	NSString *tripHeadsign;
}

- (id)initWithDictionary:(id)dic;

@property (nonatomic, retain) NSString *routeID;
@property (nonatomic, retain) NSString *shapeID;
@property (nonatomic, retain) NSString *tripHeadsign;

@end
