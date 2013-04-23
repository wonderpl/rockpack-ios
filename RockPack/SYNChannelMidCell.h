//
//  SYNChannelMidCell.h
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNChannelMidCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView* panelSelectedImageView;

@property (nonatomic) BOOL specialSelected;

- (void) setChannelImageViewImage: (NSString*) imageURLString;
- (void) setChannelTitle: (NSString*) titleString;


@end
