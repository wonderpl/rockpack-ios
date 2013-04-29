//
//  SYNCoverThumbnailCell.h
//  rockpack
//
//  Created by Nick Banks on 25/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNCoverThumbnailCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *coverImageView;

- (void) setCoverImageWithURLString: (NSString*) imageURLString;

@end