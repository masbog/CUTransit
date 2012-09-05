//
//  CUWalk.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CUPoint;

@interface CUWalk : NSObject {
	CUPoint *begin;
	CUPoint *end;
	float distance;
}

- (id)initWithDictionary:(id)dic;

@property (nonatomic, retain) CUPoint *begin;
@property (nonatomic, retain) CUPoint *end;
@property (nonatomic) float distance;

@end
