//
//  CUResponse.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "CUError.h"

@implementation CUError

@synthesize code, message;

- (void)dealloc {
	[message release];
	[super dealloc];
}

@end
