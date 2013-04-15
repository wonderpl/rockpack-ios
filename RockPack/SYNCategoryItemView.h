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
    @private TabItemType type;
    
}

@property (nonatomic, strong) UIImageView* glowImageView;

@property (nonatomic, strong) UILabel* label;

- (id)initWithTabItemModel:(TabItem*)tabItemModel;
-(void)makeHighlighted;

-(void)makeFaded;

-(void)makeStandard;

-(void)resizeForOrientation:(UIInterfaceOrientation)orientation;

@end
