//
//  SYNInboxOverlayViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 21/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "User.h"
#import <UIKit/UIKit.h>

@class SYNSearchBoxViewController;

#define kSideNavigationSearchCloseNotification @"SideNavigationSearchCloseNotification"

typedef enum {
    SideNavigationStateHidden = 0,
    SideNavigationStateHalf,
    SideNavigationStateFull

} SideNavigationState;

@interface SYNSideNavigationViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate> {
   
}

@property (nonatomic) SideNavigationState state;
@property (nonatomic, weak) User* user;
@property (nonatomic, strong) NSString* keyForSelectedPage;

//iPhone specific
@property (nonatomic, strong) SYNSearchBoxViewController* searchViewController;

-(void)reset;
-(void)deselectAllCells;
-(void)setSelectedCellByPageName:(NSString*)pageName;
@end
