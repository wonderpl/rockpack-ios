//
//  SYNFriendThumbnailCell.m
//  rockpack
//
//  Created by Michael Michailidis on 22/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFriendThumbnailCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNFriendThumbnailCell

-(void)awakeFromNib
{
    self.plusSignView.hidden = YES;
    
    self.nameLabel.font = [UIFont rockpackFontOfSize:self.nameLabel.font.pointSize];
    
}

-(void)setDisplayName:(NSString*)name
{
    
    // name label //
    
    CGRect nameLabelFrame = self.nameLabel.frame;
    
    if(IS_IPAD)
    {
        CGSize correctSize = [name sizeWithFont:self.nameLabel.font
                              constrainedToSize:CGSizeMake(self.frame.size.width, 200.0)
                                  lineBreakMode:NSLineBreakByWordWrapping];
        
        
        nameLabelFrame.size = correctSize;
        
        // NSLog(@"height:%f, title:%@", correctSize.height, name);
        
        if(nameLabelFrame.size.height > 30.0)
        {
            nameLabelFrame.size.height = 30.0;
            self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        }
        
    }
    
    
    
    self.nameLabel.frame = nameLabelFrame;
    
    self.nameLabel.text = name;
    
    
    
}



@end
