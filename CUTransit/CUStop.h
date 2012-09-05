//
//  CUStop.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CUStop : NSObject <MKAnnotation> {
	NSString *stopID;
	NSString *stopName;
	NSString *code;
	CLLocationCoordinate2D coordinate;
	
	// internal use
	int score;
}

- (id)initWithDictionary:(id)dic;
- (id)dictionary;

@property (nonatomic, retain) NSString *stopID;
@property (nonatomic, retain) NSString *stopName;
@property (nonatomic, retain) NSString *code;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) int score;

@end
