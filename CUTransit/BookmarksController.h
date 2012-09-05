//
//  BookmarksController.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookmarksController : UITableViewController {
	NSMutableArray *stops;
	int bookmarkRevision;
}

@property (nonatomic, retain) NSMutableArray *stops;

@end
