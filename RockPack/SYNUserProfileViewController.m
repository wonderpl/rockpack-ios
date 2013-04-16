//
//  SYNUserProfileViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 12/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNUserProfileViewController.h"
#import "User.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "AppConstants.h"

@interface SYNUserProfileViewController ()

@end

@implementation SYNUserProfileViewController

-(id)initWithDelegate:(id<SYNUserProfileViewDelegate>)delegate
{
    if(self = [super init])
    {
        self.delegate = delegate;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fullNameLabel.font = [UIFont boldRockpackFontOfSize:30];
    self.userNameLabel.font = [UIFont rockpackFontOfSize:14.0];
    
    // pack
    
    UITapGestureRecognizer* tapGesture;
    
    if(self.delegate)
    {
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(userSpaceTapped:)];
        
        
        [self.view addGestureRecognizer:tapGesture];
        
    }
    
    
    
    [self pack];
  
}

-(void)pack
{
    
    CGRect textRect = CGRectZero;
    textRect.size = [self.fullNameLabel.text sizeWithFont:self.fullNameLabel.font];
    CGRect referenceRect = self.profileImageView.frame;
    textRect.origin = CGPointMake(referenceRect.origin.x + referenceRect.size.width + 15.0,
                                  referenceRect.origin.y + 10.0);
    self.fullNameLabel.frame = textRect;
    
    textRect.origin = CGPointMake(textRect.origin.x,
                                  textRect.origin.y + textRect.size.height - 2.0);
    textRect.size = [self.userNameLabel.text sizeWithFont:self.userNameLabel.font];
    
    self.userNameLabel.frame = textRect;
}



-(void)setChannelOwner:(ChannelOwner*)channelOwner
{
    
    if([channelOwner isKindOfClass:[User class]])
    {
        
        self.fullNameLabel.text = ((User*)channelOwner).fullName;
        
    }
    
    self.userNameLabel.text = channelOwner.displayName;
    
    [self.profileImageView setAsynchronousImageFromURL: [NSURL URLWithString: channelOwner.thumbnailURL]
                                      placeHolderImage: [UIImage imageNamed:@"AvatarProfile.png"]];
    
    
    [self pack];
}





@end
