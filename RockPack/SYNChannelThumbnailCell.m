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
#import "UIImageView+WebCache.h"



@interface SYNChannelThumbnailCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *byLabel;

@end


@implementation SYNChannelThumbnailCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
    self.displayNameLabel.font = [UIFont rockpackFontOfSize: self.displayNameLabel.font.pointSize];
    self.byLabel.font = [UIFont rockpackFontOfSize: self.byLabel.font.pointSize];
    
    if (IS_IOS_7_OR_GREATER)
    {
        self.displayNameLabel.frame = CGRectMake(self.displayNameLabel.frame.origin.x, self.displayNameLabel.frame.origin.y - 1.0f, self.displayNameLabel.frame.size.width, self.displayNameLabel.frame.size.height);
    }
}


- (void) prepareForReuse
{
    [super prepareForReuse];
    
    [self.imageView.layer removeAllAnimations];
    [self.layer removeAllAnimations];
    
    [self.imageView setImageWithURL: nil];
}


- (void) setViewControllerDelegate: (id) viewControllerDelegate
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

- (NSString *) glossImageName
{
    NSString *imageName = @"GlossChannelThumbnail";
    
    // Use different image for iPhone
    if (IS_IPHONE)
    {
        imageName = @"GlossChannelProfile";
    }
    
    return imageName;
}

@end
