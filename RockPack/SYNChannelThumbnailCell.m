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
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
    self.displayNameLabel.font = [UIFont rockpackFontOfSize: self.displayNameLabel.font.pointSize];
    self.byLabel.font = [UIFont rockpackFontOfSize: self.byLabel.font.pointSize];
    
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


@end
