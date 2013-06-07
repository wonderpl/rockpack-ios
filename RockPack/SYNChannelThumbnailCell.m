//
//  SYNChannelThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNChannelThumbnailCell.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"

@interface SYNChannelThumbnailCell ()

@property (nonatomic, strong) IBOutlet UILabel* byLabel;



@end

@implementation SYNChannelThumbnailCell

@synthesize viewControllerDelegate = _viewControllerDelegate;
@synthesize shouldAnimate;
@synthesize imageUrlString = _imageUrlString;

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
    self.displayNameLabel.font = [UIFont rockpackFontOfSize: self.displayNameLabel.font.pointSize];
    self.byLabel.font = [UIFont rockpackFontOfSize: self.byLabel.font.pointSize];
    
    self.deleteButton.hidden = YES;
    
    self.shouldAnimate = YES;
}


- (void) showDeleteButton: (BOOL) showDeleteButton
{
    self.deleteButton.hidden = showDeleteButton ? FALSE : TRUE;
}


- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;
    
    
    [self.displayNameButton addTarget:self.viewControllerDelegate
                               action:@selector(displayNameButtonPressed:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.deleteButton addTarget: self.viewControllerDelegate
                          action: @selector(channelDeleteButtonTapped:)
                forControlEvents: UIControlEventTouchUpInside];
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


// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    [self.imageView cancelCurrentImageLoad];
    [self.imageView.layer removeAllAnimations];
    [self.layer removeAllAnimations];
    
    [self.imageView setImageWithURL:nil];
    
    self.deleteButton.hidden = TRUE;
    
}

-(void)setImageUrlString:(NSString *)imageUrlString
{
    if(!imageUrlString) // cancel the existing network operation
    {
        [self.imageView setImageWithURL: nil
                       placeholderImage: [UIImage imageNamed: @"PlaceholderChannel.png"]
                                options: SDWebImageRetryFailed];
    }
    
    if(_imageUrlString && [_imageUrlString isEqualToString:imageUrlString])
    {
 
        return;
    }
    
        
    
    _imageUrlString = imageUrlString;
    
    [self.imageView setImageWithURL: [NSURL URLWithString: _imageUrlString]
                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannel.png"]
                            options: SDWebImageRetryFailed];
    
}


@end
