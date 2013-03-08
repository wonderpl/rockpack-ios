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
@property (nonatomic, strong) IBOutlet UIImageView *selectedGlossImageView;
@property (nonatomic, strong) IBOutlet UIImageView *defaultGlossImageView;

@end


@implementation SYNVideoThumbnailSmallCell

@synthesize colour = _colour;

- (void) awakeFromNib
{
    [super awakeFromNib];

    static NSManagedObjectContext *mainManagedObjectContext = nil;
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 10.0f];
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

#pragma mark - Asynchronous image loading support

- (void) setVideoImageViewImage: (NSString*) imageURLString
{
    __weak SYNVideoThumbnailSmallCell *weakSelf = self;
    
    [self.imageView setAsynchronousImageFromURL: [NSURL URLWithString: imageURLString]
     completionHandler: ^(UIImage *fetchedImage, NSURL *url, BOOL isInCache)
     {         
         dispatch_async(SYNVideoThumbnailSmallCell.sharedImageProcessingQueue, ^
         {
             // Just do image processing on background thread
             CGImageRef imageRef = [fetchedImage imageBlackAndWhite2: [UIColor whiteColor]];
             
             dispatch_async(dispatch_get_main_queue(), ^
             {
                 // Do any image processing on a background thread
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
    // We need to clean up any asynchronous image uploads
    self.imageView.image = nil;
    self.colour = FALSE;
}

@end
