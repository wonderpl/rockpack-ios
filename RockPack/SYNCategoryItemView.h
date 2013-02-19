//
//  SYNCategoryItemView.h
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabItem.h"

typedef enum {
    TabItemTypeMain,
    TabItemTypeSub
} TabItemType;

@interface SYNCategoryItemView : UIView {
    
}

@property (nonatomic, strong) UIImageView* topGlowImageView;

@property (nonatomic, strong) UILabel* label;

- (id)initWithTabItemModel:(TabItem*)tabItemModel andFrame:(CGRect)frame;
-(void)makeHighlightedWithImage:(BOOL)withImage;

-(void)makeFaded;

-(void)makeStandard;

@end
