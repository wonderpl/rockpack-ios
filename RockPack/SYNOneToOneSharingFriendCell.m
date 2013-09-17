//
//  SYNOneToOneSharingFriendCell.m
//  rockpack
//
//  Created by Michael Michailidis on 17/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOneToOneSharingFriendCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNOneToOneSharingFriendCell

-(void)awakeFromNib
{
    
    self.nameLabel.font = [UIFont rockpackFontOfSize:self.nameLabel.font.pointSize];
    
    
    
    
}

-(void)setDisplayName:(NSString*)name
{
    
   
    
    self.nameLabel.text = name;
    
    
    
}
@end
