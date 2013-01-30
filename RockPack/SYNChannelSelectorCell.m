//
//  SYNChannelSelectorCell.m
//  rockpack
//
//  Created by Nick Banks on 28/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNChannelSelectorCell.h"

@interface SYNChannelSelectorCell ()

@property (readwrite, nonatomic, weak) IBOutlet UIImageView *imageView;

@end


@implementation SYNChannelSelectorCell

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNChannelSelectorCell"
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


- (void) setChannelImageViewImage: (NSString*) imageURLString
{
    [self.imageView setImageFromURL: [NSURL URLWithString: imageURLString]
                   placeHolderImage: nil];
}

// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    
    self.imageView.image = nil;
}

// TODO: WE NEED TO PUT THIS JAGGIE REDUCTION IN...

//        NSString *imageName = [NSString stringWithFormat: @"ChannelCreationCover%d.png", (indexPath.row % 10) + 1];
//
//        // Now add a 2 pixel transparent edge on the image (which dramatically reduces jaggies on transformation)
//        UIImage *image = [UIImage imageNamed: imageName];
//        CGRect imageRect = CGRectMake( 0 , 0 , image.size.width + 4 , image.size.height + 4 );
//
//        UIGraphicsBeginImageContext(imageRect.size);
//        [image drawInRect: CGRectMake(imageRect.origin.x + 2, imageRect.origin.y + 2, imageRect.size.width - 4, imageRect.size.height - 4)];
//        CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationHigh);
//        image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();


//        channelCarouselCell.imageView.image = image;
//
//        channelCarouselCell.imageView.layer.shouldRasterize = YES;
//        channelCarouselCell.imageView.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
//        channelCarouselCell.imageView.clipsToBounds = NO;
//        channelCarouselCell.imageView.layer.masksToBounds = NO;

// End of clever jaggie reduction

@end
