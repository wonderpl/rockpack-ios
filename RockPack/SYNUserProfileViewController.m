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
#import "SYNDeviceManager.h"

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
    if([[SYNDeviceManager sharedInstance] isIPhone])
    {
        self.fullNameLabel.font = [UIFont rockpackFontOfSize:17.0f];
        [self.fullNameLabel removeFromSuperview];
        self.fullNameLabel.frame = CGRectMake(44.0f, 0.0f, 150, 34);
        [self.fullNameLabel sizeToFit];
        CGPoint center = self.view.center;
        CGRect newFrame = self.view.frame;
        newFrame.size.width = 34.0f+self.fullNameLabel.frame.size.width;
        self.view.frame = newFrame;
        [self.view addSubview:self.fullNameLabel];
        self.fullNameLabel.center = CGPointMake(44.0f + self.fullNameLabel.frame.size.width/2.0f, 21.0f);
        self.view.center = center;
    }
    else
    {
        CGSize maxSize = [self.fullNameLabel.text sizeWithFont:self.fullNameLabel.font];
        CGRect selfFrame = self.view.frame;
        if (maxSize.width + self.fullNameLabel.frame.origin.x > selfFrame.size.width)
        {
            selfFrame.size.width = maxSize.width + self.fullNameLabel.frame.origin.x + 30.0;
            self.view.frame = selfFrame;
        }
        
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
    
    UIImage* placeholderImage = [UIImage imageNamed: @"PlaceholderAvatarProfile.png"];
    
    if(![channelOwner.thumbnailURL isEqualToString:@""]) // there is a url string
    {
        NSArray *thumbnailURLItems = [channelOwner.thumbnailURL componentsSeparatedByString:@"/"];
        
        // whatever is set to be the default size by the server (ex. 'thumbnail_small') //
        NSString* thumbnailSizeString = thumbnailURLItems[5];
        
        
        NSString* thumbnailUrlString = [channelOwner.thumbnailURL stringByReplacingOccurrencesOfString:thumbnailSizeString withString:@"thumbnail_medium"];
        
        [self.profileImageView setImageWithURL: [NSURL URLWithString: thumbnailUrlString]
                              placeholderImage: placeholderImage
                                       options: SDWebImageRetryFailed];
    }
    else
    {
        self.profileImageView.image = placeholderImage;
    }
    
    
    
    [self pack];
}





@end
