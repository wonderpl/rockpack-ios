//
//  SYNHomeSectionHeaderView.m
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNHomeSectionHeaderView.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/CoreAnimation.h>

@interface SYNHomeSectionHeaderView ()

@property (nonatomic, strong) IBOutlet UIImageView *highlightedSectionView;
@property (nonatomic, strong) IBOutlet UIImageView *sectionView;

@end

@implementation SYNHomeSectionHeaderView



- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.sectionTitleLabel.font = [UIFont rockpackFontOfSize: 18.0f];
    self.highlightedSectionView.hidden = TRUE;
    self.sectionView.hidden = FALSE;
}

// Need to do this outside awakeFromNib as the delegate is not set at that point
- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;
    
    // Add button targets
    [self.refreshButton addTarget: _viewControllerDelegate
                           action: @selector(userTouchedRefreshButton:)
                 forControlEvents: UIControlEventTouchUpInside];
}


- (void) setFocus: (BOOL) focus
{
    if (focus)
    {
        self.highlightedSectionView.hidden = FALSE;
        self.sectionView.hidden = TRUE;
    }
    else
    {
        self.highlightedSectionView.hidden = TRUE;
        self.sectionView.hidden = FALSE;
    }
}


// We need to ensure that there are no active animations (i.e. the Refresh button) when the cell is re-used
- (void) prepareForReuse
{
    self.refreshButton.selected = FALSE;
    self.refreshView.hidden = TRUE;
    [self.refreshButton.layer removeAllAnimations];
}


- (void) spinRefreshButton: (BOOL) spin
{
    if (spin)
    {
        self.refreshButton.selected = TRUE;
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue
                         forKey: kCATransactionDisableActions];
        
        CGRect frame = [self.refreshButton frame];
        self.refreshButton.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.refreshButton.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
        [CATransaction commit];
        
        [CATransaction begin];
        [CATransaction setValue: (id)kCFBooleanFalse
                         forKey: kCATransactionDisableActions];
        
        [CATransaction setValue: [NSNumber numberWithFloat:2.0]
                         forKey: kCATransactionAnimationDuration];
        
        CABasicAnimation *animation;
        animation = [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat: 0.0];
        animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
        animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
        animation.delegate = self;
        [self.refreshButton.layer addAnimation: animation
                                        forKey: @"rotationAnimation"];
        [CATransaction commit];
    }
    else
    {
        self.refreshButton.selected = FALSE;
        [self.refreshButton.layer removeAllAnimations];
    }

}


// Restarts the spin animation on the button when it ends. This is why we set the delegate of the animation above
- (void) animationDidStop: (CAAnimation *) theAnimation
                 finished: (BOOL) finished
{
	if (finished)
	{
		[self spinRefreshButton: TRUE];
	}
}

@end

