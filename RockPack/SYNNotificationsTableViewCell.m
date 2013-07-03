//
//  SYNNotificationsTableViewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNNotificationsTableViewCell.h"
#import "UIFont+SYNFont.h"
#import "SYNDeviceManager.h"
#import "SYNNotificationsTableViewController.h"


@implementation SYNNotificationsTableViewCell

@synthesize thumbnailImageView;
@synthesize messageTitle = _messageTitle;
@synthesize delegate = _delegate;
@synthesize read = _read;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        
        // == frames == //
        
        imageViewRect = CGRectMake(8.0, 8.0, 60.0, 60.0);
        
        
        
        
        // == Profile Image View == //
        
        self.imageView.frame = imageViewRect;
        
        
        // == Main Text == //
        
        
        
        self.textLabel.frame = CGRectMake(74.0, 10.0, 0.0, 0.0); // width, height will be set below
        self.textLabel.font = [UIFont rockpackFontOfSize:14.0];
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.numberOfLines = 3;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.textColor = [UIColor colorWithRed:(40.0/255.0)
                                                   green:(45.0/255.0)
                                                    blue:(51.0/255.0)
                                                   alpha:(1.0)];
        
        // == Subtitle == //
        
        
        self.detailTextLabel.font = [UIFont rockpackFontOfSize:12.0];
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        self.detailTextLabel.textColor = [UIColor colorWithRed:(187.0/255.0)
                                                         green:(187.0/255.0)
                                                          blue:(187.0/255.0)
                                                         alpha:(1.0)];
        
        // == Channel image view == //
        
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 60, 60.0)]; // x, y will be set below
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.thumbnailImageView.clipsToBounds = TRUE;
        [self addSubview:self.thumbnailImageView];
        
        
        // == Divider Image View == //
        
        dividerImageView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 362.0, 2.0)];
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



- (void) layoutSubviews {
    
    [super layoutSubviews];
    
    // Image Vsiew //
    
    self.imageView.frame = mainImageButton.frame = imageViewRect;
    
    
    self.textLabel.frame = CGRectMake(76.0,
                                      (mainTextSize.height > 40.0 ? 6.0 : 12.0),
                                      mainTextSize.width,
                                      mainTextSize.height);
    
    
    // Thumbnail - Place at the end
    
    CGRect thumbnailImageViewFrame = self.imageView.frame;
    thumbnailImageViewFrame.origin.x = self.frame.size.width - 68.0;
    thumbnailImageViewFrame.origin.y = self.imageView.frame.origin.y;
    
    self.thumbnailImageView.frame = secondaryImageButton.frame = thumbnailImageViewFrame;
    
    
    // Details
    
    CGRect detailsFrame = CGRectMake(76.0, 12.0, mainTextSize.width, 20.0f);
    detailsFrame.origin.y = self.textLabel.frame.origin.y + self.textLabel.frame.size.height - (mainTextSize.height > 40.0 ? 4.0 : 0.0);
    self.detailTextLabel.frame = detailsFrame;
    
    dividerImageView.center = CGPointMake(self.center.x, self.frame.size.height);
    
    if(_read)
        self.backgroundColor = [UIColor clearColor];
    else
        self.backgroundColor = [UIColor colorWithRed:(226.0/255.0) green:(231.0/255.0) blue:(231.0/255.0) alpha:(1.0)];
    
}




#pragma mark - Accesssors

-(void)setDelegate:(SYNNotificationsTableViewController *)newDelegate
{
    
    
    if(delegate && newDelegate && delegate == newDelegate) // assign once
        return;
    
    // we can pass nil to remove observers
    
    [mainImageButton removeTarget:delegate action:@selector(mainImageTableCellPressed:) forControlEvents:UIControlEventTouchUpInside];
    [secondaryImageButton removeTarget:delegate action:@selector(itemImageTableCellPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    delegate = newDelegate;
    
    if(!delegate)
        return;
    
    [mainImageButton addTarget:delegate action:@selector(mainImageTableCellPressed:) forControlEvents:UIControlEventTouchUpInside];
    [secondaryImageButton addTarget:delegate action:@selector(itemImageTableCellPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
}


-(SYNNotificationsTableViewController*)delegate
{
    return _delegate;
}


-(void)setMessageTitle:(NSString *)messageTitle
{
    
    // == main text label == //
    
    messageTitle = @"ALLAN has liked on of your videos although he";
    
    
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:2];
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:messageTitle];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [messageTitle length])];
    
    
    CGRect textLabelFrame = self.textLabel.frame;
    CGFloat maxWidth = [SYNDeviceManager.sharedInstance isIPad] ? 200.0 : 170.0 ;
    mainTextSize = [messageTitle sizeWithFont:self.textLabel.font
                            constrainedToSize:CGSizeMake(maxWidth, 500.0)
                                lineBreakMode:self.textLabel.lineBreakMode];
    
    
    textLabelFrame.size = mainTextSize;
    
    
    self.textLabel.frame = textLabelFrame;
    
    //self.textLabel.text = messageTitle;
    self.textLabel.attributedText = attributedString;
    
}

-(NSString*)messageTitle
{
    return self.textLabel.text;
}



@end
