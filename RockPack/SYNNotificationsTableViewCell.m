//
//  SYNNotificationsTableViewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNotificationsTableViewCell.h"
#import "UIFont+SYNFont.h"

#define kNotificationCellTextWidth 200.0

@implementation SYNNotificationsTableViewCell

@synthesize thumbnailImageView;
@synthesize messageTitle = _messageTitle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // == Profile Image View == //
        
        self.imageView.frame = CGRectMake(4.0, 4.0, 60.0, 60.0);
        self.imageView.image = [UIImage imageNamed:@"AvatarProfile"];
        self.imageView.backgroundColor = [UIColor blueColor];
        
        // == Main Text == //
        
        
        
        self.textLabel.frame = CGRectMake(74.0, 8.0, kNotificationCellTextWidth, 0.0);
        self.textLabel.font = [UIFont rockpackFontOfSize:14.0];
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.numberOfLines = 2;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.textColor = [UIColor colorWithRed:(40.0/255.0)
                                                   green:(45.0/255.0)
                                                    blue:(51.0/255.0)
                                                   alpha:(1.0)];
        
        // == Subtitle == //
        
        self.detailTextLabel.backgroundColor = [UIColor clearColor]; 
        self.detailTextLabel.font = [UIFont rockpackFontOfSize:12.0];
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        self.detailTextLabel.textColor = [UIColor colorWithRed:(187.0/255.0)
                                                         green:(187.0/255.0)
                                                          blue:(187.0/255.0)
                                                         alpha:(1.0)];
        
        // == Channel image view == //
        
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(200.0, 4.0, 60, 60.0)];
        self.thumbnailImageView.image = [UIImage imageNamed:@"AvatarProfile"];
        [self addSubview:self.thumbnailImageView];
        
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    

    // Configure the view for the selected state
    
    
}

- (void) layoutSubviews {
    
    [super layoutSubviews];
    
    
    
    
    self.textLabel.frame = CGRectMake(76.0, 14.0, mainTextSize.width, mainTextSize.height);
    
    
    //self.textLabel.backgroundColor = [UIColor greenColor];
    
    
    // place at the end
    
    CGRect thumbnailImageViewFrame = self.thumbnailImageView.frame;
    thumbnailImageViewFrame.origin.x = self.frame.size.width - 70.0;
    
    self.thumbnailImageView.frame = thumbnailImageViewFrame;
    
    // details
    
    CGRect detailsFrame = self.detailTextLabel.frame;
    detailsFrame.origin.y = self.textLabel.frame.origin.y + self.textLabel.frame.size.height;
    self.detailTextLabel.frame = detailsFrame;
}

#pragma mark - Accessors

-(void)setMessageTitle:(NSString *)messageTitle
{
    
    // == main text label == //
    
    CGRect textLabelFrame = self.textLabel.frame;
    CGSize maxSize = CGSizeMake(kNotificationCellTextWidth, 500.0);
    mainTextSize = [messageTitle sizeWithFont:self.textLabel.font
                                         constrainedToSize:maxSize
                                             lineBreakMode:self.textLabel.lineBreakMode];
    
    
    textLabelFrame.size = mainTextSize;
    
    
    self.textLabel.frame = textLabelFrame;
    
    self.textLabel.text = messageTitle;
    
    
    
    
}
-(NSString*)messageTitle
{
    return self.textLabel.text;
}
@end
