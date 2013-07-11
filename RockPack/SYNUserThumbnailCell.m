//
//  SYNUserThumbnailCell.m
//  rockpack
//
//  Created by Michael Michailidis on 08/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNUserThumbnailCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@implementation SYNUserThumbnailCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.nameLabel.font = [UIFont rockpackFontOfSize: self.nameLabel.font.pointSize];
    self.usernameLabel.font = [UIFont rockpackFontOfSize: self.usernameLabel.font.pointSize];
    
    self.nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.nameLabel.numberOfLines = 2;
    
    float gray_ratio = (183.0f/255.0f);
    self.usernameLabel.textColor = [UIColor colorWithRed:gray_ratio green:gray_ratio blue:gray_ratio alpha:1.0];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = UIScreen.mainScreen.scale;
    
    if(self.borderView)
    {
        float color_ratio = (223.0/255.0);
        self.borderView.backgroundColor = [UIColor colorWithRed:color_ratio green:color_ratio blue:color_ratio alpha:1.0];
    }
    
}

-(void)setDisplayName:(NSString*)name andUsername:(NSString*)username
{
    
    // name label //
    
    CGRect nameLabelFrame = self.nameLabel.frame;
    CGRect usernameLabelFrame = self.usernameLabel.frame;
    
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
        
        usernameLabelFrame.origin.y = nameLabelFrame.origin.y + nameLabelFrame.size.height - 6.0;
    }
    
    
    
    self.nameLabel.frame = nameLabelFrame;
    
    self.nameLabel.text = name;
    
    
    // username label //
    
    self.usernameLabel.text = username;
    [self.usernameLabel sizeToFit];
    
    
    self.usernameLabel.frame = usernameLabelFrame;
    
}

-(void)setImageUrlString:(NSString *)imageUrlString
{
    
    if(!imageUrlString || [imageUrlString isEqualToString:@""]) // cancel the existing network operation
    {
        [self.imageView setImageWithURL: nil
                       placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
                                options: SDWebImageRetryFailed];
    }
    
    
    [self.imageView setImageWithURL: [NSURL URLWithString: imageUrlString]
                   placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
                            options: SDWebImageRetryFailed];
    
}


@end
