//
//  StopDatabase.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "StopDatabase.h"

#define MAX_SEARCH_RESULTS_COUNT 20
#define INFINITY_DISTANCE 1000000

@implementation StopDatabase

static NSArray *_stops = nil;
static NSMutableDictionary *_stopNames = nil;

+ (NSArray*)stops {
	if (_stops)
		return _stops;
	
	NSMutableArray *ret = [NSMutableArray array];
	_stopNames = [[NSMutableDictionary alloc] init];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"stops_compressed" ofType:@"txt"];
	NSData *data = [NSData dataWithContentsOfFile:path];
	id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	
	// stop_id = i
	// stop_name = n
	// code = c
	// stop_points = p
	// stop_lat = l
	// stop_lon = o
	
	NSArray *stops = [obj objectForKey:@"stops"];
	for (NSDictionary *dic in stops) {
		CUStop *stop = [[CUStop alloc] init];
		stop.stopID = [dic objectForKey:@"i"];
		stop.stopName = [dic objectForKey:@"n"];
		stop.code = [dic objectForKey:@"c"];
		
		[_stopNames setObject:stop.stopName forKey:stop.stopID];
		
		NSArray *points = [dic objectForKey:@"p"];
		if ([points count] > 0) {
			NSDictionary *point = [points objectAtIndex:0];
			
			stop.coordinate = CLLocationCoordinate2DMake([[point objectForKey:@"l"] doubleValue], [[point objectForKey:@"o"] doubleValue]);
		}
		[ret addObject:stop];
		[stop release];
	}
	
	_stops = [ret retain];
	
	return ret;
}

+ (NSArray*)sortedStops {
	return [self stops]; // because we've already sorted them in the file
}

+ (NSString*)stopNameForStopID:(NSString*)stopID {
	NSUInteger loc = [stopID rangeOfString:@":"].location;
	if (loc != NSNotFound) {
		stopID = [stopID substringToIndex:loc];
	}
	return [_stopNames objectForKey:stopID];
}

// modified Levenshtein distance
static inline int editDistance(const char *s, const char *t) {
	if (s[0] != t[0])
		return INFINITY_DISTANCE;
	size_t lenS = strlen(s);
	size_t lenT = strlen(t);
	if (lenS == 2)
		return (lenT == 2 && s[1] == t[1]) ? 0 : INFINITY_DISTANCE;
	int d[lenS][lenT];
	for (size_t i=0; i<lenS; i++)
		d[i][0] = i;
	for (size_t j=1; j<lenT; j++)
		d[0][j] = j;
	for (size_t i=1; i<lenS; i++) {
		for (size_t j=1; j<lenT; j++) {
			if (s[i] == t[j]) {
				d[i][j] = d[i-1][j-1];
			} else {
				int tmp = MIN(d[i-1][j], d[i][j-1]);
				d[i][j] = MIN(tmp, d[i-1][j-1]) + 1;
			}
		}
	}
	return (d[lenS-1][lenT-1] <= ((lenS<=3) ? 1 : 2)) ? d[lenS-1][lenT-1] : INFINITY_DISTANCE;
}

static inline BOOL matches(NSArray *comps, NSArray *stopComps, int *score) {
	NSUInteger nComps = [comps count];
	NSUInteger nStopComps = [stopComps count];
	int maxScore = 0;
	for (NSUInteger i=0; i<nComps; i++) {
		BOOL found = NO;
		NSString *comp = [comps objectAtIndex:i];
		const char *compStr = [comp UTF8String];
		for (NSUInteger j=0; j<nStopComps; j++) {
			NSString *stopComp = [stopComps objectAtIndex:j];
			if (i < nComps - 1) {
				//if ([comp isEqualToString:stopComp]) {
				int tmp = editDistance(compStr, [stopComp UTF8String]);
				if (tmp < INFINITY_DISTANCE) {
					if (tmp > maxScore)
						maxScore = tmp;
					found = YES;
					break;
				}
			} else {
				NSUInteger lenS = [comp length];
				NSUInteger lenT = [stopComp length];
				
				if (lenS <= lenT+1) {
					stopComp = [stopComp substringToIndex:MIN(lenS, lenT)];
					//if ([stopComp hasPrefix:comp]) {
					int tmp = editDistance(compStr, [stopComp UTF8String]);
					if (tmp < INFINITY_DISTANCE) {
						if (tmp > maxScore)
							maxScore = tmp;
						found = YES;
						break;
					}
				}
			}
		}
		if (!found)
			return NO;
	}
	*score = maxScore;
	return YES;
}

static NSInteger stopSortByScore(id num1, id num2, void *context) {
	int v1 = ((CUStop*)num1).score;
	int v2 = ((CUStop*)num2).score;
	if (v1 < v2)
		return NSOrderedAscending;
	else if (v1 > v2)
		return NSOrderedDescending;
	return [((CUStop*)num1).stopName compare:((CUStop*)num2).stopName];
}

+ (NSArray*)stopsWithQuery:(NSString*)query {
	// Algorithm
	// - sanitize query (trim, remove double whitespace, to lowercase)
	// - break query into components
	// - go through list of stops, evaluate scores
	//
	// how to evaluate
	// - sanitize stop name
	// - if matched exactly, highest score
	// - if prefixed exactly, high score
	// - break stop name into components
	// - if matched exactly (allow reordering), high score
	//
	// Once broken into components, we will not allow prefix except for the last component.
	//
	// Cases that we should test:
	// "illinois union" -> "Illini Union"
	// "main and goodwin" -> "Goodwin and Main"
	
	NSMutableArray *ret = [NSMutableArray array];
	query = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	query = [query lowercaseString];
	query = [query stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	query = [query stringByReplacingOccurrencesOfString:@"." withString:@""];
	NSArray *comps = [query componentsSeparatedByString:@" "];
	
	if ([query length] == 1) {
		for (CUStop *stop in _stops) {
			NSString *stopName = stop.stopName;
			stopName = [stopName lowercaseString];
			if ([stopName hasPrefix:query]) {
				[ret addObject:stop];
				if ([ret count] >= MAX_SEARCH_RESULTS_COUNT)
					break;
			}
		}
		return ret;
	}
	
	for (CUStop *stop in _stops) {
		NSString *stopName = stop.stopName;
		stopName = [stopName lowercaseString];
		stopName = [stopName stringByReplacingOccurrencesOfString:@"." withString:@""];
		if ([stopName hasPrefix:query]) {
			stop.score = 0;
			[ret addObject:stop];
		} else {
			NSArray *stopComps = [stopName componentsSeparatedByString:@" "];
			int score;
			if (matches(comps, stopComps, &score)) {
				stop.score = 10000 + score;
				[ret addObject:stop];
			}
		}
	}
	return [ret sortedArrayUsingFunction:stopSortByScore context:NULL];
}

@end
