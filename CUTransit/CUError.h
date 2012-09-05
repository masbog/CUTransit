//
//  CUResponse.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CUError : NSObject {
	int code;
	NSString *message;
}

@property (nonatomic) int code;
@property (nonatomic, retain) NSString *message;

@end
