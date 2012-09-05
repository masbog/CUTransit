//
//  CUPoint.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CUPoint : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *name;
	NSString *stopID;
	NSString *time;
}

- (id)initWithDictionary:(id)dic;

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *stopID;
@property (nonatomic, retain) NSString *time;

@end
