//
//  SYNInboxOverlayViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 21/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "User.h"
#import <UIKit/UIKit.h>

@class SYNSearchBoxViewController;

#define kSideNavigationSearchCloseNotification @"SideNavigationSearchCloseNotification"

typedef enum {
    SideNavigationStateHidden = 0,
    SideNavigationStateHalf,
    SideNavigationStateFull

} SideNavigationState;

@interface SYNSideNavigatorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
   
}

@property (nonatomic) SideNavigationState state;
@property (nonatomic, weak) User* user;
@property (nonatomic, strong) NSString* keyForSelectedPage;
@property (nonatomic, strong) UIButton* captiveButton;
@property (nonatomic, strong) UIView* darkOverlay;

//iPhone specific
@property (nonatomic, strong) SYNSearchBoxViewController* searchViewController;

-(void)reset;
-(void)deselectAllCells;
-(void)setSelectedCellByPageName:(NSString*)pageName;
-(void)presentSearchBarToFront;

- (void) displayFromPushNotification;

@end
