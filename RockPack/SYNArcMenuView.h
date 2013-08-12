//
//  SYNArcMenuView.h
//  rockpack
//
//  Created by Nick Banks on 12/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//
//  Based on https://github.com/levey/AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.

#import <UIKit/UIKit.h>
#import "SYNArcMenuItem.h"

@class SYNArcMenuView;

@protocol SYNArcMenuViewDelegate <NSObject>

- (void) arcMenu: (SYNArcMenuView *) menu
         didSelectIndex: (NSInteger) idx;

@optional

- (void) arcMenuDidFinishAnimationClose: (SYNArcMenuView *) menu;
- (void) arcMenuDidFinishAnimationOpen: (SYNArcMenuView *) menu;

@end

@interface SYNArcMenuView : UIView <SYNArcMenuItemDelegate>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *highlightedImage;
@property (nonatomic, strong) UIImage *contentImage;
@property (nonatomic, strong) UIImage *highlightedContentImage;

@property (nonatomic, assign) CGFloat nearRadius;
@property (nonatomic, assign) CGFloat endRadius;
@property (nonatomic, assign) CGFloat farRadius;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGFloat timeOffset;
@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGFloat menuWholeAngle;
@property (nonatomic, assign) CGFloat expandRotation;
@property (nonatomic, assign) CGFloat closeRotation;
@property (nonatomic, assign) CGFloat animationDuration;

- (id) initWithFrame: (CGRect) frame
           startItem: (SYNArcMenuItem *) startItem
         optionMenus: (NSArray *) aMenusArray;

@end



