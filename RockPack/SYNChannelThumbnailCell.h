//
//  SYNChannelThumbnailCell.h
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"

@interface SYNChannelThumbnailCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *displayNameLabel;
@property (nonatomic, strong) IBOutlet UIButton *displayNameButton;
@property (nonatomic, strong) IBOutlet UIButton* deleteButton;
@property (nonatomic, strong) IBOutlet UIImageView* shadowOverlayImageView;

@property (nonatomic, strong) NSString* imageUrlString;
@property (nonatomic, strong) NSString* dataIndentifier;

@property (nonatomic) BOOL shouldAnimate;

@property (nonatomic, weak) Channel* channel;

- (void) setChannelTitle: (NSString*) titleString;
- (void) showDeleteButton: (BOOL) showDeleteButton;

// This is used to indicate the UIViewController that
@property (nonatomic, weak) UIViewController *viewControllerDelegate;

@end
