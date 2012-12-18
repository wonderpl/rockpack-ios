//
//  SYNThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNVideoThumbnailCell.h"
#import "UIFont+SYNFont.h"

@interface SYNVideoThumbnailCell ()

@property (nonatomic, strong) IBOutlet UIImageView *highlightedBackgroundView;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundView;

@end

@implementation SYNVideoThumbnailCell

@synthesize viewControllerDelegate = _viewControllerDelegate;

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNVideoThumbnailCell"
                                                              owner: self
                                                            options: nil];
        
        if ([arrayOfViews count] < 1)
        {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex: 0] isKindOfClass: [UICollectionViewCell class]])
        {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex: 0];
    }
    
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.maintitle.font = [UIFont boldRockpackFontOfSize: 17.0f];
    self.subtitle.font = [UIFont rockpackFontOfSize: 15.0f];
    self.rockItNumber.font = [UIFont boldRockpackFontOfSize: 17.0f];
    self.highlightedBackgroundView.hidden = TRUE;
}


- (void) setFocus: (BOOL) focus
{
    if (focus)
    {
        self.highlightedBackgroundView.hidden = FALSE;
    }
    else
    {
        self.highlightedBackgroundView.hidden = TRUE;
    }
}


// Need to do this outside awakeFromNib as the delegate is not set at that point
- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;
    
    // Add dragging to video thumbnail view
    UILongPressGestureRecognizer *longPressOnThumbnailGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget: self.viewControllerDelegate
                                                                                                                        action: @selector(longPressThumbnail:)];
    
    [self.imageView addGestureRecognizer: longPressOnThumbnailGestureRecognizer];
    
    // Add button targets
    [self.rockItButton addTarget: self.viewControllerDelegate
                          action: @selector(toggleThumbnailRockItButton:)
                forControlEvents: UIControlEventTouchUpInside];
    
    
    [self.addItButton addTarget: self.viewControllerDelegate
                         action: @selector(touchThumbnailAddItButton:)
               forControlEvents: UIControlEventTouchUpInside];
}



@end
