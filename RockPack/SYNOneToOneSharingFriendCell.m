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
    
    // name label //
    
    
//    CGRect nameLabelFrame = self.nameLabel.frame;
//    
//    CGSize correctSize = [name sizeWithFont:self.nameLabel.font
//                          constrainedToSize:CGSizeMake(self.frame.size.width - 8.0, 200.0)
//                              lineBreakMode:NSLineBreakByWordWrapping];
//    
//    
//    nameLabelFrame.size = correctSize;
//    
//    // NSLog(@"height:%f, title:%@", correctSize.height, name);
//    
//    nameLabelFrame.size.height = correctSize.height;
//    
//    self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
//    nameLabelFrame.origin.y = self.frame.size.height - nameLabelFrame.size.height - 8.0;
//    
//    self.nameLabel.frame = nameLabelFrame;
    
    self.nameLabel.text = name;
    
    
    
}
@end
