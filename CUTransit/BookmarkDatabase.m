//
//  BookmarkDatabase.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "BookmarkDatabase.h"

@implementation BookmarkDatabase

static sqlite3 *db;
static int _bookmarkRevision = 0;

+ (NSString*)bookmarkPath {
	NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:@"bookmarks.db"];
}

+ (void)initialize {
	NSString *bookmarkPath = [self bookmarkPath];
	NSFileManager *fm = [NSFileManager defaultManager];
	if (![fm fileExistsAtPath:bookmarkPath]) {
		sqlite3_open([bookmarkPath UTF8String], &db);
		
		char *query;
		query = "CREATE TABLE \"meta\" (\"key\" TEXT NOT NULL, \"value\" TEXT, PRIMARY KEY (\"key\"))";
		sqlite3_exec(db, query, NULL, NULL, NULL);
		query = "INSERT INTO meta (key, value) VALUES ('version', '1')";
		sqlite3_exec(db, query, NULL, NULL, NULL);
		query = "CREATE TABLE \"stops\" (\"stopID\" TEXT NOT NULL, \"data\" TEXT NOT NULL, "
		"\"sort\" INTEGER, PRIMARY KEY (\"stopID\"))";
		sqlite3_exec(db, query, NULL, NULL, NULL);
	} else {
		sqlite3_open([bookmarkPath UTF8String], &db);
	}
}

+ (NSMutableArray*)stops {
	NSMutableArray *stops = [NSMutableArray array];
	NSString *query = [NSString stringWithFormat:@"SELECT data FROM stops ORDER BY sort"];
	
	sqlite3_exec(db, "begin", NULL, NULL, NULL);
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
		while (sqlite3_step(stmt) == SQLITE_ROW) {
			const unsigned char *tmp = sqlite3_column_text(stmt, 0);
			if (!tmp)
				continue;
			NSData *data = [NSData dataWithBytes:tmp length:strlen((const char*)tmp)];
			id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
			CUStop *stop = [[CUStop alloc] initWithDictionary:obj];
			[stops addObject:stop];
			[stop release];
		}
	}
	sqlite3_finalize(stmt);
	sqlite3_exec(db, "commit", NULL, NULL, NULL);
	
	return stops;
}

+ (void)addStop:(CUStop*)stop {
	NSDictionary *dic = [stop dictionary];
	NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
	NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSString *query = [NSString stringWithFormat:@"INSERT INTO stops (stopID, data, sort) VALUES ('%@', '%@', %.0lf)", stop.stopID, s, CFAbsoluteTimeGetCurrent()-351370000];
	sqlite3_exec(db, [query UTF8String], NULL, NULL, NULL);
	
	[s release];
	
	_bookmarkRevision++;
}

+ (void)removeStop:(CUStop*)stop {
	NSString *query = [NSString stringWithFormat:@"DELETE FROM stops WHERE stopID = '%@'", stop.stopID];
	sqlite3_exec(db, [query UTF8String], NULL, NULL, NULL);
	
	_bookmarkRevision++;
}

+ (void)reorderStops:(NSArray*)stops {
	sqlite3_exec(db, "BEGIN", NULL, NULL, NULL);

	for (NSUInteger i = 0; i < [stops count]; i++) {
		CUStop *stop = [stops objectAtIndex:i];
		
		NSString *query = [NSString stringWithFormat:@"UPDATE stops SET sort = %d WHERE stopID = '%@'", i, stop.stopID];
		sqlite3_exec(db, [query UTF8String], NULL, NULL, NULL);
	}
	
	sqlite3_exec(db, "COMMIT", NULL, NULL, NULL);
	
	_bookmarkRevision++;
}

+ (BOOL)hasStop:(CUStop*)stop {
	NSString *query = [NSString stringWithFormat:@"SELECT 1 FROM stops WHERE stopID = '%@'", stop.stopID];
	
	BOOL found = NO;
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
		if (sqlite3_step(stmt) == SQLITE_ROW) {
			found = YES;
		}
	}
	sqlite3_finalize(stmt);
	
	return found;
}

+ (int)revision {
	return _bookmarkRevision;
}

@end
