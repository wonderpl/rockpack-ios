//
//  SYNChannelMidCell.m
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//


#import "AppConstants.h"
#import "SYNChannelMidCell.h"
#import "SYNDeletionWobbleLayoutAttributes.h"
#import "SYNTouchGestureRecognizer.h"
#import "UIFont+SYNFont.h"
#import "UIImage+Tint.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNChannelMidCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *lowlightImageView;

@end


@implementation SYNChannelMidCell

@synthesize specialSelected;

#pragma mark - Cell lifcycle

- (void) awakeFromNib
{
    [super awakeFromNib];
  
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
    
    self.specialSelected = NO;
    
    // Required to make cells look good when wobbling (delete)
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = UIScreen.mainScreen.scale;
}

- (void) prepareForReuse
{
    [self.imageView.layer removeAllAnimations];
    [self.imageView setImageWithURL: nil];
}


#pragma mark - Setters

- (void) setChannelTitle: (NSString*) titleString
{
    CGFloat originalWidth = self.titleLabel.frame.size.width;
    
    self.titleLabel.text = titleString;
    [self.titleLabel sizeToFit];
    CGRect titleFrame = self.titleLabel.frame;
    
    titleFrame.size.width = originalWidth;
    titleFrame.origin.y = self.imageView.frame.size.height - (IS_IOS_7_OR_GREATER ? 8.0f : 0.0f) -titleFrame.size.height + 2.0;
    
    self.titleLabel.frame = titleFrame;
    
}


- (void) setSpecialSelected: (BOOL)value
{
    if(value)
    {
        self.panelSelectedImageView.hidden = NO;
    }
    else
    {
        self.panelSelectedImageView.hidden = YES;
    }
}


- (BOOL) specialSelected
{
    return !self.panelSelectedImageView.hidden;
}


//- (void) showChannel: (UITapGestureRecognizer *) recognizer
//{
//    // Just need to reference any button in the cell (as there is no longer an actual video button)
//    [self.viewControllerDelegate channelTapped: self];
//}
//
//
//- (void) showMenu: (UILongPressGestureRecognizer *) recognizer
//{
//    [self.viewControllerDelegate arcMenuUpdateState: recognizer];
//}


// This is used to lowlight the gloss image on touch

- (NSString *) glossImageName
{
    NSString *imageName = @"GlossChannelMid";
    
    // Use different image for iPhone
    if (IS_IPHONE)
    {
        imageName = @"GlossChannelProfile";
    }
    
    return imageName;
}

@end
