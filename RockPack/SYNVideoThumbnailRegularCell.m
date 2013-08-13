//
//  SYNVideoThumbnailRegularCell.m
//  rockpack
//
//  Created by Nick Banks on 03/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNVideoThumbnailRegularCell.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"

@interface SYNVideoThumbnailRegularCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end


@implementation SYNVideoThumbnailRegularCell

- (void) awakeFromNib
{
    [super awakeFromNib];

        // Add long-press and tap recognizers (once only per cell)
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                                   action: @selector(showMenu:)];
    self.longPress.delegate = self;
    [self addGestureRecognizer: self.longPress];

    
    // Tap for exiting delete mode
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                       action: @selector(showVideo:)];
    self.tap.delegate = self;
    [self addGestureRecognizer: self.tap];

    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
}


#pragma mark - Switch between display and edit modes

- (void) setDisplayMode: (kChannelThumbnailDisplayMode) displayMode
{
    _displayMode = displayMode;
    
    if (displayMode == kChannelThumbnailDisplayModeDisplay)
    {
        self.addItButton.hidden = NO;
        self.longPress.enabled = TRUE;
        self.tap.enabled = TRUE;
        self.deleteButton.hidden = YES;
    }
    else if (displayMode == kChannelThumbnailDisplayModeEdit)
    {
        self.addItButton.hidden = YES;
        self.longPress.enabled = FALSE;
        self.tap.enabled = FALSE;
        self.deleteButton.hidden = NO;
    }
    else if(displayMode == kChannelThumbnailDisplayModeDisplayFavourite)
    {
        self.addItButton.hidden = NO;
        self.longPress.enabled = TRUE;
        self.tap.enabled = TRUE;
        self.deleteButton.hidden = YES;
    }
    else
    {
        AssertOrLog(@"Unexpected option");
    }
}


- (void) setViewControllerDelegate: (id<SYNVideoThumbnailRegularCellDelegate>) delegate
{
    _viewControllerDelegate = delegate;
    
    // Add button targets
    
    [self.deleteButton addTarget: self.viewControllerDelegate
                          action: @selector(videoDeleteButtonTapped:)
                forControlEvents: UIControlEventTouchUpInside];
    
    [self.addItButton addTarget: self.viewControllerDelegate
                         action: @selector(videoAddButtonTapped:)
               forControlEvents: UIControlEventTouchUpInside];
}


// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // We need to clean up any asynchronous image uploads
    [self.imageView.layer removeAllAnimations];
    [self.imageView setImageWithURL:nil];
}

#pragma mark - Gesture regognizer callbacks

- (void) showVideo: (UILongPressGestureRecognizer *) recognizer
{
    [self.viewControllerDelegate videoButtonPressed: self.addItButton];
}


- (void) showMenu: (UILongPressGestureRecognizer *) recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.viewControllerDelegate showMenuTriggered: recognizer];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self.viewControllerDelegate showMenuDismissed: recognizer];
    }
}

@end
