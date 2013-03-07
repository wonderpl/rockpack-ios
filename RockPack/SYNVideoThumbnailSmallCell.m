//
//  SYNVideoThumbnailSmallCell.m
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoThumbnailSmallCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "UIImage+ImageProcessing.h"


@interface SYNVideoThumbnailSmallCell ()

@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet UIImage *colourImage;
@property (nonatomic, strong) IBOutlet UIImage *monochromeImage;

@end


@implementation SYNVideoThumbnailSmallCell

@synthesize colour = _colour;

- (void) awakeFromNib
{
    [super awakeFromNib];

    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 10.0f];
}

#pragma mark - Asynchronous image loading support

- (void) setVideoImageViewImage: (NSString*) imageURLString
{
    __weak SYNVideoThumbnailSmallCell *weakSelf = self;
    
    [self.imageView setAsynchronousImageFromURL: [NSURL URLWithString: imageURLString]
     completionHandler: ^(UIImage *fetchedImage, NSURL *url, BOOL isInCache)
     {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
         {
             // Do any image processing on a background thread
             weakSelf.colourImage = fetchedImage;
             weakSelf.monochromeImage = fetchedImage.imageBlackAndWhite;
             
             dispatch_async(dispatch_get_main_queue(), ^
             {
                 if (!isInCache)
                 {
                     [UIView transitionWithView: weakSelf.imageView.superview
                                       duration: kFromCacheAnimationDuration
                                        options: UIViewAnimationOptionTransitionCrossDissolve animations: ^
                      {
                          [weakSelf displayThumbnail: weakSelf.isColour];
                      }
                      completion: nil];
                 }
                 else
                 {
                    [weakSelf displayThumbnail: weakSelf.isColour];
                 }
             });
         });
      }
      errorHandler: nil];
}

- (void) displayThumbnail: (BOOL) isColour
{
    if (isColour)
    {
        self.imageView.image = self.colourImage;
        self.mainView.alpha = 1.0f;
    }
    else
    {
        self.imageView.image = self.monochromeImage;
        self.mainView.alpha = 0.6f;
    }
}

- (void) setColour: (BOOL) colour
{
    if (self.colour != colour)
    {
        [UIView transitionWithView: self.imageView.superview
                          duration: kFromCacheAnimationDuration
                           options: UIViewAnimationOptionTransitionCrossDissolve animations: ^
         {
             [self displayThumbnail: colour];
         }
         completion: ^(BOOL b)
         {
             _colour = colour;
         }];
    }
}

// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // We need to clean up any asynchronous image uploads
    self.imageView.image = nil;
    self.colour = FALSE;
}

@end
