//
//  SYNCoverThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 25/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCoverThumbnailCell.h"
#import "UIImageView+ImageProcessing.h"
#import "AppConstants.h"

@interface SYNCoverThumbnailCell ()

@property (nonatomic, assign)  BOOL coverSelected;
@property (nonatomic, strong) IBOutlet UIImageView *selectedOverlayImageView;

@end


@implementation SYNCoverThumbnailCell

@synthesize coverSelected = _displayMode;

- (void) awakeFromNib
{
    [super awakeFromNib];
}


#pragma mark - Selection

- (void) setSelected: (BOOL) selected
{
    [super setSelected: selected];
    
    if (selected)
    {
        // Guard against multiple repeated selections
        if (self.selectedOverlayImageView.alpha == 0.0f)
        {
            [UIView animateWithDuration: kChannelEditModeAnimationDuration
                             animations: ^{
                                 self.selectedOverlayImageView.alpha = 1.0f;
                             }
                             completion: nil];
        }
    }
    else
    {
        if (self.selectedOverlayImageView.alpha == 1.0f)
        {
            [UIView animateWithDuration: kChannelEditModeAnimationDuration
                             animations: ^{
                                 self.selectedOverlayImageView.alpha = 0.0f;
                             }
                             completion: nil];
        }
    }
}


#pragma mark - Asynchronous image loading support

- (void) setCoverImageWithURLString: (NSString*) imageURLString
{
    [self.coverImageView setAsynchronousImageFromURL: [NSURL URLWithString: imageURLString]
                                    placeHolderImage: nil];
}



// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // We need to clean up any asynchronous image uploads
    self.coverImageView.image = nil;
    self.selectedOverlayImageView.alpha = 0.0f;
}

@end
