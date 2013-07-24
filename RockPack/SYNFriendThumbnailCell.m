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
    
    CGSize correctSize = [name sizeWithFont:self.nameLabel.font
                          constrainedToSize:CGSizeMake(self.frame.size.width, 200.0)
                              lineBreakMode:NSLineBreakByWordWrapping];
    
    
    nameLabelFrame.size = correctSize;
    
    // NSLog(@"height:%f, title:%@", correctSize.height, name);
    
    nameLabelFrame.size.height = correctSize.height;
    
    self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    nameLabelFrame.origin.y = self.frame.size.height - nameLabelFrame.size.height - 4.0;
    
    self.nameLabel.frame = nameLabelFrame;
    
    self.nameLabel.text = name;
    
    
    
}



@end
