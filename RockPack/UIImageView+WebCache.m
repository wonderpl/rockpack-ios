/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "objc/runtime.h"
#import "SDWebImageManager.h"

static char operationKey;

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock;
{
    [self cancelCurrentImageLoad];
    
    NSString *key = [SDWebImageManager.sharedManager cacheKeyForURL: url];
    UIImage *image = [SDWebImageManager.sharedManager.imageCache imageFromMemoryCacheForKey: key];
    
    if (image)
    {
        self.image = image;
    }
    else
    {
        self.image = placeholder;
    }

    if (url)
    {
        __weak UIImageView *wself = self;
        id<SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadWithURL: url
                                                                                     options: options
                                                                                    progress: progressBlock
                                                                                   completed:^ (UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                                             {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     __strong typeof(self) sself = wself;
                                                     
                                                     if (sself == nil)
                                                     {
                                                         // If the pointer is nil, then bail
                                                         return;
                                                     }
                                                     
                                                     if (image != nil)
                                                     {
                                                         // If we were not returned directly from the cache, then fade up
                                                         if (cacheType == SDImageCacheTypeNone)
                                                         {
                                                             [UIView transitionWithView: sself.superview
                                                                               duration: 0.35f
                                                                                options: UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                                                                             animations: ^{
                                                                                 sself.image = image;
                                                                             }
                                                                             completion: nil];
                                                         }
                                                         else
                                                         {
                                                             sself.image = image;
                                                         }
                                                         
                                                         [sself setNeedsLayout];
                                                     }
                                                     
                                                     if (completedBlock && finished)
                                                     {
                                                         completedBlock(image, error, cacheType);
                                                     }
                                                 });
                                                 
                                             }];
        
        objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)cancelCurrentImageLoad
{
    // Cancel in progress downloader from queue
    id<SDWebImageOperation> operation = objc_getAssociatedObject(self, &operationKey);
    if (operation)
    {
        [operation cancel];
        objc_setAssociatedObject(self, &operationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
