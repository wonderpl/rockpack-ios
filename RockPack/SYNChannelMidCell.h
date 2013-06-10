//
//  SYNChannelMidCell.h
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNChannelMidCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView* panelSelectedImageView;
@property (nonatomic, strong) IBOutlet UIButton* deleteButton;

@property (nonatomic, strong) NSString* dataIndentifier;

@property (nonatomic) BOOL specialSelected;

- (void) setChannelTitle: (NSString*) titleString;

- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate;


@end
