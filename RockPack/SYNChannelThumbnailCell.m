//
//  SYNChannelThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNChannelThumbnailCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"

@interface SYNChannelThumbnailCell ()

@property (nonatomic, strong) IBOutlet UILabel* byLabel;


@end

@implementation SYNChannelThumbnailCell

@synthesize viewControllerDelegate = _viewControllerDelegate;
@synthesize shouldAnimate;

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.displayNameLabel.font = [UIFont rockpackFontOfSize: 13.0f];
    self.byLabel.font = [UIFont rockpackFontOfSize: 13.0f];
    
    self.shouldAnimate = YES;
}


- (void) setChannelImageViewImage: (NSString*) imageURLString
{
    [self.imageView setAsynchronousImageFromURL: [NSURL URLWithString: imageURLString]
                               placeHolderImage: nil];
}

// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    self.imageView.image = nil;
    
}

- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;
    
    
    [self.displayNameButton addTarget:self.viewControllerDelegate
                               action:@selector(displayNameButtonPressed:)
                     forControlEvents:UIControlEventTouchUpInside];
}




@end
