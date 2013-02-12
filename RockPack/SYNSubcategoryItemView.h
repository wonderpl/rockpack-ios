//
//  SYNSubcategoryItemView.h
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Subcategory.h"

@interface SYNSubcategoryItemView : UIView

@property (nonatomic, strong) UILabel* mainLabel;

@property (nonatomic, strong) NSString* categoryId;

- (id)initWithCategory:(Subcategory *)subcategory andFrame:(CGRect)frame;

@end
