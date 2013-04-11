//
//  SYNHomeSectionHeaderView.h
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNHomeSectionHeaderView : UICollectionReusableView

@property (nonatomic, strong) IBOutlet UILabel *sectionTitleLabel;
@property (nonatomic, strong) IBOutlet UIButton *refreshButton;
@property (nonatomic, strong) IBOutlet UIView *refreshView;

// This is used to indicate the UIViewController that
@property (nonatomic, weak) UIViewController *viewControllerDelegate;

- (void) setFocus: (BOOL) focus;

@end
