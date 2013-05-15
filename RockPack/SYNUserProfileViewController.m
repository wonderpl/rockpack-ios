//
//  SYNUserProfileViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 12/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNUserProfileViewController.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "User.h"

@interface SYNUserProfileViewController ()

@end


@implementation SYNUserProfileViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.fullNameLabel.font = [UIFont boldRockpackFontOfSize:30];
    self.userNameLabel.font = [UIFont rockpackFontOfSize:12.0];
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(userDataChanged:)
                                                 name: kUserDataChanged
                                               object: nil];

    [self pack];
}


- (void) userDataChanged: (NSNotification*) notification
{
    User* currentUser = (User*)[[notification userInfo] objectForKey: @"user"];
    if(!currentUser)
        return;
    
    [self setChannelOwner:currentUser];
}


- (void) pack
{
    CGRect textRect = CGRectZero;
    textRect.size = [self.fullNameLabel.text sizeWithFont:self.fullNameLabel.font];
    CGRect referenceRect = self.profileImageView.frame;
    textRect.origin = CGPointMake(referenceRect.origin.x + referenceRect.size.width + 10.0,
                                  referenceRect.origin.y + 10.0);
    self.fullNameLabel.frame = textRect;
    
    textRect.origin = CGPointMake(textRect.origin.x,
                                  textRect.origin.y + textRect.size.height - 5.0);
    textRect.size = [self.userNameLabel.text sizeWithFont:self.userNameLabel.font];
    
    self.userNameLabel.frame = textRect;
}


- (void) setChannelOwner: (ChannelOwner*) channelOwner
{
    _channelOwner = channelOwner;
    
    NSString* userName;
    if ([channelOwner isKindOfClass:[User class]])
    {
        User* ownerAsUser = (User*)channelOwner;
        userName = [ownerAsUser.fullName uppercaseString];
        
        if([userName isEqualToString:@""])
        {
            userName = ownerAsUser.username;
        }
        else
        {
            self.userNameLabel.text = ownerAsUser.username;
            self.userNameLabel.text = @"";
        }
        
        
    }
    else
    {
        userName = channelOwner.displayName;
        self.userNameLabel.text = @"";
    }
    
    self.fullNameLabel.text = userName;
    
    CGSize maxSize = [self.fullNameLabel.text sizeWithFont:self.fullNameLabel.font];
    CGRect selfFrame = self.view.frame;
    if (maxSize.width + self.fullNameLabel.frame.origin.x > selfFrame.size.width)
    {
        selfFrame.size.width = maxSize.width + self.fullNameLabel.frame.origin.x + 30.0;
        self.view.frame = selfFrame;
    }

    

    [self.profileImageView setImageWithURL: [NSURL URLWithString: channelOwner.thumbnailURL]
                          placeholderImage: [UIImage imageNamed: @"AvatarProfile.png"]
                                   options: SDWebImageRetryFailed];
    
    
    [self pack];
}





@end
