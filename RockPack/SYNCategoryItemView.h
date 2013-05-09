//
//  SYNCategoryItemView.h
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Genre;

typedef enum {
    TabItemTypeMain,
    TabItemTypeSub
} TabItemType;

@interface SYNCategoryItemView : UIView
{
    @private TabItemType type;
    @private UIColor* grayColor; 
}

@property (nonatomic, strong) UIImageView* glowImageView;
@property (nonatomic, strong) UILabel* label;

- (id) initWithTabItemModel: (Genre*) tabItemModel;

- (id) initWithLabel: (NSString *) label
              andTag: (int) tag;

- (void) makeHighlighted;
- (void) makeFaded;
- (void) makeStandard;

/**
 Helper method for resizing the item view which is assumed to have flexible width depending on orientation and a fixed height.
 
 @param orientation The orientation to adapt to
 @param height the fixed view height
 */
 
-(void) resizeForOrientation: (UIInterfaceOrientation) orientation
                  withHeight: (CGFloat) height;

@end
