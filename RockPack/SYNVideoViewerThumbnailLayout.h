//
//  SYNVideoViewerThumbnailLayout.h
//  rockpack
//
//  Created by Nick Banks on 01/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNVideoViewerThumbnailLayout : UICollectionViewFlowLayout

@property (strong, nonatomic, strong) NSIndexPath *selectedItemIndexPath;

- (UICollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath: (NSIndexPath *) indexPath;

@end
