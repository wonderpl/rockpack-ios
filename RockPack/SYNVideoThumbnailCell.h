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

@interface SYNVideoThumbnailCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *maintitle;
@property (nonatomic, strong) IBOutlet UILabel *subtitle;
@property (nonatomic, strong) IBOutlet UIButton *rockItButton;
@property (nonatomic, strong) IBOutlet UIButton *packItButton;
@property (nonatomic, strong) IBOutlet UIButton *addItButton;
@property (nonatomic, strong) IBOutlet UIButton *shareItButton;
@property (nonatomic, strong) IBOutlet UILabel *packItNumber;
@property (nonatomic, strong) IBOutlet UILabel *rockItNumber;

- (void) setThirdButtonType: (int) buttonType;
- (void) setHighlighted: (BOOL) highlighted;

@end
