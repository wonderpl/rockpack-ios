//
//  SYNVideoQueueCell.h
//  rockpack
//
//  Created by Nick Banks on 19/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNVideoQueueCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

- (void) setVideoImageViewImage: (NSString*) imageURLString;

@end
