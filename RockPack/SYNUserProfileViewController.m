//
//  SYNUserProfileViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 12/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNUserProfileViewController.h"
#import "User.h"

@interface SYNUserProfileViewController ()

@end

@implementation SYNUserProfileViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
  
}


-(void)setChannelOwner:(ChannelOwner*)channelOwner
{
    if([channelOwner isKindOfClass:[User class]])
    {
        
        self.fullNameLabel.text = ((User*)channelOwner).fullName;
        
    }
    
    self.userNameLabel.text = channelOwner.displayName;
}




@end
