//
//  SYNFriendThumbnailCell.h
//  rockpack
//
//  Created by Michael Michailidis on 22/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNFriendThumbnailCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;

@property (nonatomic, strong) IBOutlet UIImageView *plusSignView;


-(void)setDisplayName:(NSString*)name;

@end
