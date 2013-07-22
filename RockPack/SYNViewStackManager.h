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
}


@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, weak) SYNSideNavigatorViewController *sideNavigatorController;
@property (nonatomic, weak) SYNMasterViewController *masterController;

+ (id) manager;


- (void) popToRootController;
- (void) popToController: (UIViewController *) controller;
- (void) popController;
- (void) pushController: (SYNAbstractViewController *) controller;

- (void) presentModallyController: (UIViewController *) controller;

- (void) viewProfileDetails: (ChannelOwner *) channelOwner;
- (void) viewChannelDetails: (Channel *) channel withAutoplayId: (NSString *) autoplayId;
- (void) viewChannelDetails: (Channel *) channel;


- (void) hideModallyController;

- (void) hideSideNavigator;

@end
