//
//  SYNChannelThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "MKNetworkKit.h"
#import "SYNChannelThumbnailCell.h"
#import "UICollectionViewCell+AsyncImage.h"
#import "UIFont+SYNFont.h"

@interface SYNChannelThumbnailCell ()

@property (nonatomic, strong) MKNetworkOperation* channelImageLoadingOperation;
@property (nonatomic, strong) NSString* loadingChannelImageViewURLString;

@end

@implementation SYNChannelThumbnailCell

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNChannelThumbnailCell"
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
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 17.0f];
    self.userNameLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.rockItNumberLabel.font = [UIFont boldRockpackFontOfSize: 14.0f];
}


- (void) setChannelImageViewImage: (NSString*) imageURLString
{
    self.loadingChannelImageViewURLString = imageURLString;
    
    [self loadAndCacheImageInView: self.imageView
                    withURLString: self.loadingChannelImageViewURLString
         andImageLoadingOperation: self.channelImageLoadingOperation];
}

// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{

    self.imageView.image = nil;
    [self.channelImageLoadingOperation cancel];
}

@end
