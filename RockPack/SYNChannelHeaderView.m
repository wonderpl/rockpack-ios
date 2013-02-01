//
//  SYNChannelHeaderView.m
//  rockpack
//
//  Created by Nick Banks on 04/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "UIFont+SYNFont.h"
#import "SYNChannelHeaderView.h"

@implementation SYNChannelHeaderView

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNChannelHeaderView"
                                                              owner: self
                                                            options: nil];
        
        if ([arrayOfViews count] < 1)
        {
            return nil;
        }
        
        if (![arrayOfViews[0] isKindOfClass: [UICollectionViewCell class]])
        {
            return nil;
        }
        
        self = arrayOfViews[0];
    }
    
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.videosLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.followersLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.videoCountLabel.font = [UIFont boldRockpackFontOfSize: 18.0f];
    self.followersCountLabel.font = [UIFont boldRockpackFontOfSize: 18.0f];
}

// Need to do this outside awakeFromNib as the delegate is not set at that point
- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;
    
    // Set up editable description text view (this is somewhat specialy, as it has a resizeable glow around it
    self.channelDescriptionTextView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.channelDescriptionTextView.font = [UIFont rockpackFontOfSize: 15.0f];
	self.channelDescriptionTextView.minNumberOfLines = 1;
	self.channelDescriptionTextView.maxNumberOfLines = 4;
    self.channelDescriptionTextView.backgroundColor = [UIColor clearColor];
    self.channelDescriptionTextView.textColor = [UIColor colorWithRed: 0.725f green: 0.812f blue: 0.824f alpha: 1.0f];
	self.channelDescriptionTextView.delegate = (id)self.viewControllerDelegate;
    self.channelDescriptionTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    [self.channelDescriptionTextView resignFirstResponder];
    
    // Add highlighted box
    UIImage *rawEntryBackground = [UIImage imageNamed: @"MessageEntryInputField.png"];
    
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth: 13
                                                                       topCapHeight: 22];
    
    self.channelDescriptionHightlightView = [[UIImageView alloc] initWithImage: entryBackground];
    self.channelDescriptionHightlightView.frame = CGRectInset(self.channelDescriptionTextView.frame, -10, -10);
    self.channelDescriptionHightlightView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.channelDescriptionTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.channelDescriptionHightlightView.hidden = TRUE;
    
    [self.channelDescriptionTextContainerView addSubview: self.channelDescriptionHightlightView];
    self.channelDescriptionTextContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
}

@end
