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

@interface SYNViewStackManager : NSObject


@property (nonatomic, weak) UINavigationController* navigationController;
@property (nonatomic, weak) SYNSideNavigatorViewController* sideNavigatorController;

+(id)manager;


-(void)popToRootController;
-(void)popToController:(UIViewController*)controller;
-(void)popController;
-(void)pushController:(SYNAbstractViewController*)controller;

- (void) viewProfileDetails: (ChannelOwner *) channelOwner;
-(void) viewChannelDetails: (Channel*) channel withAutoplayId:(NSString*)autoplayId;
- (void) viewChannelDetails: (Channel*) channel;

@end
