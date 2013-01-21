//
//  SYNFriendThumbnailCell.h
//  rockpack
//
//  Created by Nick Banks on 21/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNFriendThumbnailCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *friendImageView;
@property (nonatomic, strong) IBOutlet UILabel *forename;
@property (nonatomic, strong) IBOutlet UILabel *surname;

// This is used to indicate the UIViewController that
@property (nonatomic, weak) UIViewController *viewControllerDelegate;

- (void) setFriendImageViewImage: (NSString*) imageURLString;

@end
