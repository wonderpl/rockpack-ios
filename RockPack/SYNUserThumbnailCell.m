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
    
    
    
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = UIScreen.mainScreen.scale;
    
}

-(void)setDisplayName:(NSString*)name andUsername:(NSString*)username
{
    
    // name label //
    
    CGSize correctSize = [name sizeWithFont:self.nameLabel.font
                          constrainedToSize:CGSizeMake(self.frame.size.width, 200.0)
                              lineBreakMode:self.nameLabel.lineBreakMode];
    
    
    CGRect nameLabelFrame = self.nameLabel.frame;
    nameLabelFrame.size = correctSize;
    
    self.nameLabel.frame = nameLabelFrame;
    
    self.nameLabel.text = name;
    
    
    // username label //
    
    self.usernameLabel.text = username;
    [self.usernameLabel sizeToFit];
    
    CGRect usernameLabelFrame = self.usernameLabel.frame;
    usernameLabelFrame.origin.y = nameLabelFrame.origin.y + nameLabelFrame.size.height;
    self.usernameLabel.frame = usernameLabelFrame;
    
}

-(void)setImageUrlString:(NSString *)imageUrlString
{
    
    if(!imageUrlString) // cancel the existing network operation
    {
        [self.imageView setImageWithURL: nil
                       placeholderImage: [UIImage imageNamed: @"PlaceholderChannel.png"]
                                options: SDWebImageRetryFailed];
    }
    
    
    [self.imageView setImageWithURL: [NSURL URLWithString: imageUrlString]
                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannel.png"]
                            options: SDWebImageRetryFailed];
    
}


@end
