//
//  StopInfoController.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "CUConnection.h"

@interface StopInfoController : UITableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {
	CUStop *stop;
	UIButton *bookmarkButton;
}

- (id)initWithStop:(CUStop*)s;

@property (nonatomic, retain) CUStop *stop;

@end
