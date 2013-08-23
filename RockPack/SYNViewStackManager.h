//
//  SYNViewStackManager.h
//  rockpack
//
//  Created by Michael Michailidis on 04/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYNAbstractViewController;
@class ChannelOwner;
@class Channel;
@class SYNSideNavigatorViewController;
@class SYNMasterViewController;

@interface SYNViewStackManager : NSObject {
    UIViewController *modalViewController;
    UIView* popoverView;
    UIView* backgroundView;
}

typedef void(^ViewStackReturnBlock)(void);

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, weak) SYNSideNavigatorViewController *sideNavigatorController;
@property (nonatomic, weak) SYNMasterViewController *masterController;
@property (nonatomic) BOOL searchBarOriginSideNavigation;
@property (nonatomic, copy) ViewStackReturnBlock returnBlock;

@property (nonatomic) NSInteger indexToOpenSide;

+ (id) manager;


- (void) popToRootController;
- (void) popToController: (UIViewController *) controller;
- (void) popController;
- (void) pushController: (SYNAbstractViewController *) controller;

- (void) presentModallyController: (UIViewController *) controller;
- (void) presentPopoverView:(UIView*)view;
- (void)removePopoverView;

-(void)addSubvievOnTopOfEverything:(UIView*)view;

- (void) viewProfileDetails: (ChannelOwner *) channelOwner;
- (void) viewChannelDetails: (Channel *) channel withAutoplayId: (NSString *) autoplayId;
- (void) viewChannelDetails: (Channel *) channel;

-(void)dismissSearchBar;
-(void)presentSearchBar;

-(void)dismissSearchBarTotal:(BOOL)total;

- (void) hideModalController;

- (void) hideSideNavigator;
- (void) showSideNavigator;

-(void) openSideNavigatorToIndex:(NSInteger)index;

- (void) displaySideNavigatorFromPushNotification;

@end
