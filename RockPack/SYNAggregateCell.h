//
//  SYNAggregateCell.h
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFont+SYNFont.h"

@interface SYNAggregateCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView* userThumbnailImageView;
@property (nonatomic, strong) IBOutlet UILabel* messageLabel;

@property (nonatomic, strong) IBOutlet UIView* imageContainer;

@property (nonatomic, weak) UIViewController *viewControllerDelegate;

-(void)setCoverImagesFromArray:(NSArray*)array;

@end
