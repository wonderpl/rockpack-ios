//
//  SYNNotificationsTableViewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNotificationsTableViewCell.h"
#import "UIFont+SYNFont.h"
#import "SYNDeviceManager.h"
#import "SYNNotificationsViewController.h"


@implementation SYNNotificationsTableViewCell

@synthesize thumbnailImageView;
@synthesize messageTitle = _messageTitle;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        // == frames == //
        
        imageViewRect = CGRectMake(8.0, 6.0, 60.0, 60.0);
        
        
        
        
        // == Profile Image View == //
        
        self.imageView.frame = imageViewRect;
        
        
        
        // == Main Text == //
        
        
        
        self.textLabel.frame = CGRectMake(74.0, 8.0, 0.0, 0.0); // width, height will be set below
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
        
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 60, 60.0)]; // x, y will be set below
        self.thumbnailImageView.image = [UIImage imageNamed:@"AvatarProfile"];
        [self addSubview:self.thumbnailImageView];
        
        
        // == Divider Image View == //
        
        dividerImageView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 2.0)];
        dividerImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"NavDivider"]];
        
        [self addSubview:dividerImageView];
        
        // == Buttons == //
        
        mainImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        mainImageButton.frame = imageViewRect;
        [self addSubview:mainImageButton];
        
        secondaryImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        secondaryImageButton.frame = imageViewRect;
        [self addSubview:secondaryImageButton];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    

    // Configure the view for the selected state
    
    
}


- (void) layoutSubviews {
    
    [super layoutSubviews];
    
    // image view //
    
    self.imageView.frame = mainImageButton.frame = imageViewRect;
    
    
    self.textLabel.frame = CGRectMake(76.0, 14.0, mainTextSize.width, mainTextSize.height);
    
    
    // place at the end
    
    CGRect thumbnailImageViewFrame = self.imageView.frame;
    thumbnailImageViewFrame.origin.x = self.frame.size.width - 68.0;
    thumbnailImageViewFrame.origin.y = self.imageView.frame.origin.y;
    
    self.thumbnailImageView.frame = secondaryImageButton.frame = thumbnailImageViewFrame;
    
    // details
    
    CGRect detailsFrame = self.detailTextLabel.frame;
    detailsFrame.origin.y = self.textLabel.frame.origin.y + self.textLabel.frame.size.height;
    self.detailTextLabel.frame = detailsFrame;
    
    dividerImageView.center = CGPointMake(self.center.x, self.frame.size.height - 4.0);
}




#pragma mark - Accesssors

-(void)setDelegate:(SYNNotificationsViewController *)newDelegate
{
    
    
    if(delegate && newDelegate && delegate == newDelegate) // assign once
        return;
    
    
    [mainImageButton removeTarget:delegate action:@selector(mainImageTableCellPressed:) forControlEvents:UIControlEventTouchUpInside];
    [secondaryImageButton removeTarget:delegate action:@selector(itemImageTableCellPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    delegate = newDelegate;
    
    if(!delegate)
        return;
    
    [mainImageButton addTarget:delegate action:@selector(mainImageTableCellPressed:) forControlEvents:UIControlEventTouchUpInside];
    [secondaryImageButton addTarget:delegate action:@selector(itemImageTableCellPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
}


-(SYNNotificationsViewController*)delegate
{
    return _delegate;
}


-(void)setMessageTitle:(NSString *)messageTitle
{
    
    // == main text label == //
    
    CGRect textLabelFrame = self.textLabel.frame;
    CGFloat maxWidth = [[SYNDeviceManager sharedInstance] isIPad] ? 200.0 : 170.0 ;
    mainTextSize = [messageTitle sizeWithFont:self.textLabel.font
                            constrainedToSize:CGSizeMake(maxWidth, 500.0)
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
