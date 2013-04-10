//
//  SYNNotificationsTableViewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNotificationsTableViewCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNNotificationsTableViewCell

@synthesize thumbnailImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // == Main Text == //
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont rockpackFontOfSize:16.0];
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.numberOfLines = 2;
        self.textLabel.textColor = [UIColor colorWithRed:(40.0/255.0)
                                                   green:(45.0/255.0)
                                                    blue:(51.0/255.0)
                                                   alpha:(1.0)];
        
        // == Subtitle == //
        
        self.detailTextLabel.backgroundColor = [UIColor clearColor]; 
        self.detailTextLabel.font = [UIFont rockpackFontOfSize:16.0];
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        self.detailTextLabel.textColor = [UIColor colorWithRed:(187.0/255.0)
                                                         green:(187.0/255.0)
                                                          blue:(187.0/255.0)
                                                         alpha:(1.0)];
        
        // == thumbnail image view == //
        
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(200.0, 4.0, 48.0, 36.0)];
        self.thumbnailImageView.backgroundColor = [UIColor greenColor];
        [self addSubview:self.thumbnailImageView];
        
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect textLabelFrame = self.textLabel.frame;
    CGRect detailsTextLabelFrame = self.detailTextLabel.frame;
    
    
    self.imageView.frame = CGRectMake(4.0, 4.0, 36.0, 36.0);
    
    CGFloat textOffset = self.imageView.frame.origin.x + self.imageView.frame.size.width + 8.0;
    textLabelFrame.origin.x = textOffset;
    self.textLabel.frame = textLabelFrame;
    
    detailsTextLabelFrame.origin.x = textOffset;
    
    self.detailTextLabel.frame = detailsTextLabelFrame;
    
    // place at the end
    CGRect thumbnailImageViewFrame = self.thumbnailImageView.frame;
    thumbnailImageViewFrame.origin.x = self.frame.size.width - thumbnailImageViewFrame.size.width - 4.0;
    self.thumbnailImageView.frame = thumbnailImageViewFrame;
}

@end
