//
//  SYNArcMenuView.h
//  rockpack
//
//  Created by Nick Banks on 12/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//
//  Inspired by https://github.com/levey/AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.

#import <UIKit/UIKit.h>
#import "SYNArcMenuItem.h"

#define kShadeViewTag 123
#define kShadeViewAnimationDuration 0.25f

typedef enum : NSInteger {
    kArcMenuButtonLike = 0,
    kArcMenuButtonAdd = 1,
    kArcMenuButtonShare = 2
} kArcMenuButtonType;

typedef enum : NSInteger {
    kArcMenuInvalidComponentIndex = 999999
} kArcMenuComponentIndex;

@class SYNArcMenuView;

@protocol SYNArcMenuViewDelegate <NSObject>

- (void) arcMenu: (SYNArcMenuView *) menu
         didSelectMenuName: (NSString *) menuName
         forCellAtIndex: (NSIndexPath *) cellIndexPath
         andComponentIndex: (NSInteger) componentIndex;

- (void) arcMenuUpdateState: (UIGestureRecognizer *) recognizer
                    forCell: (UICollectionViewCell *) cell;

@optional

- (UIView *) arcMenuViewToShade;

@end

@interface SYNArcMenuView : UIView 

@property (nonatomic, assign) CGFloat activeRadius;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) CGFloat closeRotation;
@property (nonatomic, assign) CGFloat endRadius;
@property (nonatomic, assign) CGFloat expandRotation;
@property (nonatomic, assign) CGFloat farRadius;
@property (nonatomic, assign) CGFloat menuWholeAngle;
@property (nonatomic, assign) CGFloat nearRadius;
@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) NSInteger componentIndex;
@property (nonatomic, strong) UIImage *contentImage;
@property (nonatomic, strong) UIImage *highlightedContentImage;
@property (nonatomic, strong) UIImage *highlightedImage;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) id<SYNArcMenuViewDelegate> delegate;

- (id) initWithFrame: (CGRect) frame
           startItem: (SYNArcMenuItem *) startItem
         optionMenus: (NSArray *) menuItemArray
       cellIndexPath: (NSIndexPath *) cellIndexPath;

- (void) show: (BOOL) show;

- (void) positionUpdate: (CGPoint) tapPoint;

@end




