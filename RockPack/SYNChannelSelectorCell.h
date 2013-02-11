//
//  SYNChannelSelectorCell.h
//  rockpack
//
//  Created by Nick Banks on 28/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CBetterCollectionViewCell.h"

@interface SYNChannelSelectorCell : CBetterCollectionViewCell

@property (readwrite, nonatomic, weak) IBOutlet UIImageView *imageView;

- (void) setChannelImageViewImage: (NSString*) imageURLString;

@end