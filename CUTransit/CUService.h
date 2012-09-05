//
//  CUService.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CUPoint, CURoute, CUTrip;

@interface CUService : NSObject {
	CUPoint *begin;
	CUPoint *end;
	CURoute *route;
	CUTrip *trip;
}

- (id)initWithDictionary:(id)dic;

@property (nonatomic, retain) CUPoint *begin;
@property (nonatomic, retain) CUPoint *end;
@property (nonatomic, retain) CURoute *route;
@property (nonatomic, retain) CUTrip *trip;

@end
