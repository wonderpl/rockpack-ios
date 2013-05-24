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
    if ([self.channelOwner.uniqueId isEqualToString:self.channelOwner.uniqueId])
    {
        [self setChannelOwner:currentUser];
    }
}


- (void) pack
{
    if([[SYNDeviceManager sharedInstance] isIPhone])
    {
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineHeightMultiple:1.0f];
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:self.fullNameLabel.text];
        [attString addAttribute:NSParagraphStyleAttributeName
                          value:style
                          range:NSMakeRange(0, self.fullNameLabel.text.length)];
        
        self.fullNameLabel.font = [UIFont rockpackFontOfSize:17.0f];
        [self.fullNameLabel removeFromSuperview];
        self.fullNameLabel.frame = CGRectMake(42.0f, 0.0f, 150, 34);
        self.fullNameLabel.attributedText = attString;
        [self.fullNameLabel sizeToFit];
        CGPoint center = self.view.center;
        CGRect newFrame = self.view.frame;
        newFrame.size.width = 44.0f+self.fullNameLabel.frame.size.width;
        self.view.frame = newFrame;
        [self.view addSubview:self.fullNameLabel];
        self.fullNameLabel.center = CGPointMake(44.0f + self.fullNameLabel.frame.size.width/2.0f, 19.0f);
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
        
        if([userName length]>1)
        {
            userName = ownerAsUser.username;
            self.userNameLabel.text = @"";
        }
        else
        {
            self.userNameLabel.text = ownerAsUser.username;
        }
        
        
    }
    else
    {
        userName = channelOwner.displayName;
        self.userNameLabel.text = @"";
    }
    
    self.fullNameLabel.text = userName;
    
    UIImage* placeholderImage = self.profileImageView.image ? self.profileImageView.image : [UIImage imageNamed: @"PlaceholderAvatarProfile.png"];
    
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
