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
#import <QuartzCore/QuartzCore.h>

@interface SYNVideoThumbnailSmallCell ()

@property BOOL *cancelledPtr;
@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet UIImage *colourImage;
@property (nonatomic, strong) IBOutlet UIImage *monochromeImage;
@property (nonatomic, strong) IBOutlet UIImageView *selectedGlossImageView;
@property (nonatomic, strong) IBOutlet UIImageView *defaultGlossImageView;

@end


@implementation SYNVideoThumbnailSmallCell

@synthesize colour = _colour;

- (void) awakeFromNib
{
    [super awakeFromNib];

    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
    
    self.imageView.image = nil;
    self.mainView.alpha = 0.6f;
    self.colour = FALSE;
}


+ (dispatch_queue_t) sharedImageProcessingQueue
{
    static dispatch_once_t pred;
    static dispatch_queue_t imageProcessingQueue;
    
    dispatch_once(&pred, ^
    {
        imageProcessingQueue = dispatch_queue_create("com.rockpack.imageprocessing", DISPATCH_QUEUE_SERIAL);
    });
    
    return imageProcessingQueue;
}

+ (CIFilter *) sharedFilter
{
    static dispatch_once_t pred;
    static CIFilter *filter;
    
    dispatch_once(&pred, ^
                  {
                      filter = [CIFilter filterWithName: @"CIColorMonochrome"
                                          keysAndValues: @"inputIntensity", [NSNumber numberWithFloat: 1.0],
                                                         @"inputColor", [[CIColor alloc] initWithColor: [UIColor whiteColor]],
                                                         nil];
                  });
    
    return filter;
}

#pragma mark - Asynchronous image loading support

- (void) setVideoImageViewImage: (NSString*) imageURLString
{
    __weak typeof(self) weakSelf = self;
    __block BOOL cancelled = NO;
    
//    [self.profileImageView setImageWithURL: [NSURL URLWithString: channelOwner.thumbnailURL]
//                          placeholderImage: [UIImage imageNamed: @"AvatarProfile.png"]
//                                   options: SDWebImageRetryFailed];
    
    [self.imageView setAsynchronousImageFromURL: [NSURL URLWithString: imageURLString]
     completionHandler: ^(UIImage *fetchedImage, NSURL *url, BOOL isInCache)
     {         
         dispatch_async(SYNVideoThumbnailSmallCell.sharedImageProcessingQueue, ^
         {
             // Just do image processing on background thread
             CIImage *beginImage = [CIImage imageWithCGImage: fetchedImage.CGImage];
             
             // Only update the imput image each time (as opposed to creating the filter again)
             [SYNVideoThumbnailSmallCell.sharedFilter setValue: beginImage
                                                        forKey: kCIInputImageKey];
             
             CIImage *output = SYNVideoThumbnailSmallCell.sharedFilter.outputImage;

             
             CIContext *context = [CIContext contextWithOptions: nil];
             CGImageRef imageRef = [context createCGImage: output
                                                 fromRect: output.extent];
             
             dispatch_async(dispatch_get_main_queue(), ^
             {
                 if (cancelled == NO)
                 {
                     // Do any UIKit calls on the main thread
                     weakSelf.colourImage = fetchedImage;
                     
                     UIImage *newImage = [UIImage imageWithCGImage: imageRef];
                     CGImageRelease(imageRef);
                     weakSelf.monochromeImage = newImage;
                     
                     if (!isInCache)
                     {
                         [UIView transitionWithView: weakSelf.imageView
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
                 }
             });
         });
      }
      errorHandler: nil];
    
    self.cancelledPtr = &cancelled;
}

- (void) displayThumbnail: (BOOL) isColour
{
    if (isColour)
    {
        self.imageView.image = self.colourImage;
        self.mainView.alpha = 1.0f;
        self.selectedGlossImageView.hidden = FALSE;
        self.defaultGlossImageView.hidden = TRUE;
    }
    else
    {
        self.imageView.image = self.monochromeImage;
        self.mainView.alpha = 0.6f;
        self.selectedGlossImageView.hidden = TRUE;
        self.defaultGlossImageView.hidden = FALSE;
    }
}

- (void) setColour: (BOOL) colour
{
    if (self.colour != colour)
    {
        [UIView transitionWithView: self.imageView
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
    
    _colour = colour;
}

// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // Set our cancelled pointer, so we don't display any expired images
    *self.cancelledPtr = YES;
    
    [self.imageView.layer removeAllAnimations];

    [self.imageView setImageFromURL:nil];
    
    self.mainView.alpha = 0.6f;
    self.colour = FALSE;
}

@end
