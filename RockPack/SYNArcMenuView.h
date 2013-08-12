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

/*

SYNArcMenuItem *arcMenuItem1 = [[SYNArcMenuItem alloc] initWithImage: [UIImage imageNamed: @"ActionLike"]
                                                    highlightedImage: [UIImage imageNamed: @"ActionLikeHighlighted"]
                                                        contentImage: nil;
                                             highlightedContentImage: nil];

SYNArcMenuItem *arcMenuItem2 = [[SYNArcMenuItem alloc] initWithImage: [UIImage imageNamed: @"ActionAdd"]
                                                    highlightedImage: [UIImage imageNamed: @"ActionAddHighlighted"]
                                                        contentImage: nil;
                                             highlightedContentImage: nil];

SYNArcMenuItem *arcMenuItem3 = [[SYNArcMenuItem alloc] initWithImage: [UIImage imageNamed: @"ActionShare"]
                                                    highlightedImage: [UIImage imageNamed: @"ActionShareHighlighted"]
                                                        contentImage: nil;
                                             highlightedContentImage: nil];

SYNArcMenuItem *mainMenuItem = [[SYNArcMenuItem alloc] initWithImage: [UIImage imageNamed: @"ActionRingNoTouch"]
                                                   highlightedImage: [UIImage imageNamed: @"ActionRingTouchg"]
                                                       contentImage: nil
                                             highlightedContentImage: nil];

SYNArcMenuView *menu = [[SYNArcMenuView alloc] initWithFrame: self.window.bounds
                                                   startItem: mainMenuItem
                                                 optionMenus: @[arcMenuItem1, arcMenuItem2, arcMenuItem3]];
menu.delegate = self;
menu.startPoint = CGPointMake(160.0, 240.0);
menu.rotateAngle = 0.0;
menu.menuWholeAngle = M_PI / 2 2;
menu.timeOffset = 0.036f;
menu.farRadius = 140.0f;
menu.nearRadius = 110.0f;
menu.endRadius = 120.0f;

[self.window addSubview: menu];
 
*/




