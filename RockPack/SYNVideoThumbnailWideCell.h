//
//  SYNThumbnailCell.h
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    kShowAddButton = 0,
    kShowShareButton = 1
};

@interface SYNVideoThumbnailWideCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *videoImageView;
@property (nonatomic, strong) IBOutlet UIImageView *channelImageView;
@property (nonatomic, strong) IBOutlet UILabel *videoTitle;
@property (nonatomic, strong) IBOutlet UILabel *channelName;
@property (nonatomic, strong) IBOutlet UILabel *userName;
@property (nonatomic, strong) IBOutlet UIButton *rockItButton;
@property (nonatomic, strong) IBOutlet UIButton *addItButton;
@property (nonatomic, strong) IBOutlet UIButton *shareItButton;
@property (nonatomic, strong) IBOutlet UILabel *rockItNumber;

// This is used to indicate the UIViewController that 
@property (nonatomic, weak) UIViewController *viewControllerDelegate;

- (void) setFocus: (BOOL) focus;

@end
