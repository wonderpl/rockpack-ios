//
//  SYNChannelThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNChannelThumbnailCell.h"
#import "SYNTouchGestureRecognizer.h"
#import "UIFont+SYNFont.h"
#import "UIImage+Tint.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>


@interface SYNChannelThumbnailCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *lowlightImageView;
@property (nonatomic, strong) IBOutlet UILabel *byLabel;

@end


@implementation SYNChannelThumbnailCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
    self.displayNameLabel.font = [UIFont rockpackFontOfSize: self.displayNameLabel.font.pointSize];
    self.byLabel.font = [UIFont rockpackFontOfSize: self.byLabel.font.pointSize];
    
    self.deleteButton.hidden = YES;
    
    if (IS_IOS_7_OR_GREATER) {
        self.displayNameLabel.frame = CGRectMake(self.displayNameLabel.frame.origin.x, self.displayNameLabel.frame.origin.y - 1.0f, self.displayNameLabel.frame.size.width, self.displayNameLabel.frame.size.height);
    }
}


- (void) prepareForReuse
{
    [self.imageView.layer removeAllAnimations];
    [self.layer removeAllAnimations];
    
    [self.imageView setImageWithURL: nil];
    
    self.deleteButton.hidden = TRUE;
    self.lowlightImageView.image = [self lowlightImage: FALSE];
}


- (void) setViewControllerDelegate: (id<SYNChannelThumbnailCellDelegate>) viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;
    
    [self.displayNameButton addTarget: self.viewControllerDelegate
                               action: @selector(displayNameButtonPressed:)
                     forControlEvents: UIControlEventTouchUpInside];
}


- (void) setChannelTitle: (NSString *) titleString
{
    CGRect titleFrame = self.titleLabel.frame;
    
    CGSize expectedSize = [titleString sizeWithFont: self.titleLabel.font
                                  constrainedToSize: CGSizeMake(titleFrame.size.width, 500.0)
                                      lineBreakMode: self.titleLabel.lineBreakMode];
    
    titleFrame.size.height = expectedSize.height;
    titleFrame.origin.y = self.imageView.frame.size.height - titleFrame.size.height - 4.0;
    
    self.titleLabel.frame = titleFrame;
    
    
    self.titleLabel.text = titleString;
}


// If this cell is going to be re-used, then clear the image and cancel any outstanding operations

- (void) setLowlight: (BOOL) lowlight
            forPoint: (CGPoint) pointInCell
{
    self.lowlightImageView.image = [self lowlightImage: lowlight];
}


- (UIImage *) lowlightImage: (BOOL) lowlight
{
    // Default iPad gloss image
    NSString *imageName = @"GlossChannelThumbnail";
    
    // Use different image for iPhone
    if (IS_IPHONE)
    {
        imageName = @"GlossChannelProfile";
    }
    
    UIImage *glossImage = [UIImage imageNamed: imageName];
    
    if (lowlight)
    {
        UIImage *lowlightImage = [glossImage tintedImageUsingColor: [UIColor colorWithWhite: 0.0
                                                                                      alpha: 0.3]];
        return lowlightImage;
    }
    else
    {
        return glossImage;
    }
}

@end
