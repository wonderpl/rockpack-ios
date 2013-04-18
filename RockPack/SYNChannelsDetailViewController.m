//
//  SYNChannelsDetailViewController.m
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "SYNAppDelegate.h"
#import "SYNChannelHeaderView.h"
#import "SYNChannelsDetailViewController.h"
#import "SYNChannelsDetailsCreationViewController.h"
#import "SYNChannelHeaderView.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNTextField.h"
#import "UIImageView+MKNetworkKitAdditions.h"

@interface SYNChannelsDetailViewController ()

@property (nonatomic, strong) UIButton *shareButton;

@end

@implementation SYNChannelsDetailViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Google Analytics support
    self.trackedViewName = @"Channels - Detail";
    
    // Show edit and share buttons

}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reloadCollectionViews)
                                                 name: kDataUpdated
                                               object: nil];
    
//    DebugLog(@"URL for channel %@", self.channel.resourceURL);
//    
//    NSString* protocol = [self.channel.resourceURL substringWithRange:NSMakeRange(0, 5)];
//    
//    if([protocol isEqualToString:@"https"]) {
//        [appDelegate.oAuthNetworkEngine updateChannel:self.channel.resourceURL];
//    } else {
//        [appDelegate.networkEngine updateChannel: self.channel.resourceURL];
//    }
    
    
    
}

-(IBAction)tappedOnUserAvatar:(UIButton*)sender
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:kShowUserChannels object:self userInfo:@{@"ChannelOwner":self.channel.channelOwner}];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kDataUpdated
                                                  object: nil];
}


- (void) reloadCollectionViews
{
    [self.videoThumbnailCollectionView reloadData];
}


- (void) shareChannelButtonTapped: (id) sender
{
    NSString *messageString = kChannelShareMessage;
    
//  TODO: Put in cover art image?
//  UIImage *messageImage = [UIImage imageNamed: @"xyz.png"];
    
    // TODO: Put in real link
    NSURL *messageURL = [NSURL URLWithString: @"http://www.rockpack.com"];
    
    [self shareURL: messageURL
       withMessage: messageString
          fromRect: self.shareButton.frame
   arrowDirections: UIPopoverArrowDirectionUp];
}

@end
