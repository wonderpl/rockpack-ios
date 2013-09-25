//
//  SYNChannelMidCell.h
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNHighlightableCollectionViewCell.h"
#import <UIKit/UIKit.h>

@interface SYNChannelMidCell : SYNHighlightableCollectionViewCell

@property (nonatomic) BOOL specialSelected;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIImageView* panelSelectedImageView;
@property (nonatomic, strong) IBOutlet UIImageView* shadowOverlayImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

- (void) setChannelTitle: (NSString*) titleString;

@end
