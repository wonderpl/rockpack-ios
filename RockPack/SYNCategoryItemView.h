//
//  SYNCategoryItemView.h
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"

@interface SYNCategoryItemView : UIView

@property (nonatomic, strong) UILabel* mainLabel;

- (id)initWithCategory:(Category *)category andFrame:(CGRect)frame;

@end
