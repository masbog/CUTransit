//
//  BookmarksController.m
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import "BookmarksController.h"
#import "BookmarkDatabase.h"
#import "StopController.h"


@implementation BookmarksController

@synthesize stops;

- (id)init {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.title = @"Bookmarks";
		self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:0] autorelease];
	}
	return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];

	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.stops = [BookmarkDatabase stops];
	bookmarkRevision = [BookmarkDatabase revision];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (bookmarkRevision != [BookmarkDatabase revision]) {
		self.stops = [BookmarkDatabase stops];
		bookmarkRevision = [BookmarkDatabase revision];
		[self.tableView reloadData];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [stops count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	CUStop *stop = [stops objectAtIndex:indexPath.row];
	cell.textLabel.text = stop.stopName;
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		CUStop *stop = [stops objectAtIndex:indexPath.row];
		[BookmarkDatabase removeStop:stop];
		bookmarkRevision = [BookmarkDatabase revision];
		
		[stops removeObjectAtIndex:indexPath.row];
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	} 
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSDictionary *tmp = [[stops objectAtIndex:fromIndexPath.row] retain];
	[stops removeObjectAtIndex:fromIndexPath.row];
	[stops insertObject:tmp atIndex:toIndexPath.row];
	[tmp release];
	
	[BookmarkDatabase reorderStops:stops];
	bookmarkRevision = [BookmarkDatabase revision];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CUStop *stop = [stops objectAtIndex:indexPath.row];
	
	StopController *controller = [[StopController alloc] initWithStop:stop];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return YES;
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)dealloc {
	[stops release];
	[super dealloc];
}

@end
