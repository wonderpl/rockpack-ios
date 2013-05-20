//
//  SYNChannelMidCell.m
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelMidCell.h"
#import "SYNDeletionWobbleLayoutAttributes.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

@implementation SYNChannelMidCell

@synthesize specialSelected;

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
    
    self.specialSelected = NO;
    self.deleteButton.layer.opacity = 0.0f;
    
    // Required to make cells look good when wobbling (delete)
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = UIScreen.mainScreen.scale;
}


- (void) setChannelTitle: (NSString*) titleString
{
    
    CGRect titleFrame = self.titleLabel.frame;
    
    CGSize expectedSize = [titleString sizeWithFont:self.titleLabel.font
                                  constrainedToSize:CGSizeMake(titleFrame.size.width, 500.0)
                                      lineBreakMode:self.titleLabel.lineBreakMode];
    
    titleFrame.size.height = expectedSize.height;
    titleFrame.origin.y = self.imageView.frame.size.height - titleFrame.size.height - 4.0;
    
    self.titleLabel.frame = titleFrame;
    
    
    self.titleLabel.text = titleString;
    
}


- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    
    [self.deleteButton addTarget: viewControllerDelegate
                          action: @selector(channelDeleteButtonTapped:)
                forControlEvents: UIControlEventTouchUpInside];
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


#pragma mark - Cell deletion support
#pragma mark Attributes

- (void) applyLayoutAttributes: (SYNDeletionWobbleLayoutAttributes *) layoutAttributes
{
    if (layoutAttributes.isDeleteButtonHidden || self.deleteButton.enabled == FALSE)
    {
        self.deleteButton.layer.opacity = 0.0;
        [self stopWobbling];
    }
    else
    {
        self.deleteButton.layer.opacity = 1.0;
        [self startWobbling];
    }
}


#pragma mark Wobble animations

- (void) startWobbling
{
    // Rotation maths
    CABasicAnimation *quiverAnim = [CABasicAnimation animationWithKeyPath: @"transform.rotation"];
    float startAngle = M_PI/180.0;
    float stopAngle = -startAngle;
    
    // Setup animation
    quiverAnim.fromValue = [NSNumber numberWithFloat: startAngle];
    quiverAnim.toValue = [NSNumber numberWithFloat: stopAngle];
    quiverAnim.autoreverses = YES;
    quiverAnim.duration = 0.2;
    quiverAnim.repeatCount = HUGE_VALF;
    
    // Add a random time offset to stop all cells wobbling in harmony
    float timeOffset = (float)(arc4random() % 100)/100 - 0.50;
    quiverAnim.timeOffset = timeOffset;
    CALayer *layer = self.layer;
    
    // Add the animation to our layer
    [layer addAnimation: quiverAnim
                 forKey: @"wobbling"];
}


- (void) stopWobbling
{
    // Remove the animation from the layer
    CALayer *layer = self.layer;
    [layer removeAnimationForKey: @"wobbling"];
}


- (void) prepareForReuse
{
    [self stopWobbling];
    self.imageView.image = nil;
}

@end
