//
//  CUItinerary.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CUItinerary : NSObject {
	NSString *startTime;
	NSString *endTime;
	int travelTime;
	NSArray *legs;
}

- (id)initWithDictionary:(id)dic;

@property (nonatomic, retain) NSString *startTime;
@property (nonatomic, retain) NSString *endTime;
@property (nonatomic) int travelTime;
@property (nonatomic, retain) NSArray *legs;

@end
