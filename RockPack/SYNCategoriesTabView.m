//
//  SYNCategoriesTabView.m
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCategoriesTabView.h"
#import "Category.h"
#import "Subcategory.h"
#import "SYNCategoryItemView.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

#define kSecondaryTabsOffset 30.0

@interface SYNCategoriesTabView ()

@property (nonatomic, strong) UIView* dividerOverlayView;
@property (nonatomic, strong) UIView* mainTabsView;
@property (nonatomic, strong) UIView* secondaryDividerOverlay;
@property (nonatomic, strong) UIView* secondaryTabsBGView;
@property (nonatomic, strong) UIView* secondaryTabsView;
@property (nonatomic, weak) UIButton* homeButton;
@property (nonatomic, assign) BOOL useHomeButton;

@end


@implementation SYNCategoriesTabView


- (id) initWithSize: (CGFloat) totalWidth
      andHomeButton: (BOOL) useHomeButton;
{
    if ((self = [super init]))
    {
        self.useHomeButton = useHomeButton;
        
        // == Tob Bar == //
        UIImage* mainTabsBGImage = [UIImage imageNamed: @"CategoryBar"];
        CGRect mainFrame = CGRectMake(0.0, 0.0, totalWidth, mainTabsBGImage.size.height);
        self.mainTabsView = [[UIView alloc] initWithFrame:mainFrame];
        self.mainTabsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIView* bgMainTabsView = [[UIView alloc] initWithFrame: mainFrame];
        bgMainTabsView.backgroundColor = [UIColor colorWithPatternImage: mainTabsBGImage];
        bgMainTabsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        bgMainTabsView.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
        bgMainTabsView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        bgMainTabsView.layer.shadowOpacity = 0.2;
        bgMainTabsView.layer.shadowRadius = 1.0;
        
        // == Bottom Bar == //
        UIImage* secondaryTabsBGImage = [UIImage imageNamed: @"SubCategoryBar"];
        CGRect secondaryFrame = CGRectMake(0.0, 0.0, totalWidth, secondaryTabsBGImage.size.height);
        self.secondaryTabsView = [[UIView alloc] initWithFrame: secondaryFrame];
        self.secondaryTabsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.secondaryDividerOverlay = [[UIView alloc] initWithFrame:secondaryFrame];
        self.secondaryDividerOverlay.userInteractionEnabled = NO;
        self.secondaryDividerOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        
        self.secondaryTabsBGView = [[UIView alloc] initWithFrame: secondaryFrame];
        self.secondaryTabsBGView.backgroundColor = [UIColor colorWithPatternImage: secondaryTabsBGImage];
        self.secondaryTabsBGView.userInteractionEnabled = NO;
        self.secondaryTabsBGView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        CGRect masterFrame = CGRectMake(0.0, 0.0, totalWidth, mainFrame.size.height + secondaryFrame.size.height);
        self.frame = masterFrame;
        
        [self addSubview:self.secondaryTabsBGView];
        [self addSubview:self.secondaryTabsView];
        [self addSubview:self.secondaryDividerOverlay];
        
        [self addSubview: bgMainTabsView];
        [self addSubview:self.mainTabsView];
    }
    
    return self;
}


- (void) createCategoriesTab: (NSArray*) categories
{
    SYNCategoryItemView* tab = nil;
    
    self.dividerOverlayView = [[UIView alloc] initWithFrame: self.mainTabsView.frame];
    self.dividerOverlayView.userInteractionEnabled = NO;
    self.dividerOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    CGFloat nextOrigin = 0.0;
    
    if (self.useHomeButton == TRUE)
    {
        self.homeButton = [UIButton buttonWithType: UIButtonTypeCustom];
        UIImage* homeButtonImage = [UIImage imageNamed: @"IconCategoryAll"];
        self.homeButton.frame = CGRectMake(nextOrigin, 0.0, homeButtonImage.size.width, self.mainTabsView.frame.size.height);
        [self.homeButton setImage: homeButtonImage forState: UIControlStateNormal];
        
        [self.homeButton addTarget: self
                            action: @selector(homeButtonPressed)
                  forControlEvents: UIControlEventTouchUpInside];
        
        [self addSubview: self.homeButton];
    }
    else
    {
        // Create a special Other tab with tag id 0
        tab = [[SYNCategoryItemView alloc] initWithLabel: @"OTHER"
                                                  andTag: 0];
        
        [self.mainTabsView addSubview: tab];
        
        [tab addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                           action: @selector(handleMainTap:)]];
    }


    for (Category* category in categories)
    {
        tab = [[SYNCategoryItemView alloc] initWithTabItemModel: category];
        
        [self.mainTabsView addSubview: tab];
        
        [tab addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                           action: @selector(handleMainTap:)]];
    }
    
    [self addSubview: self.dividerOverlayView];
    
    //Layout tabs according to orientation
    [self refreshViewForOrientation: [[UIApplication sharedApplication] statusBarOrientation]];
}


- (UIImageView*) createDividerAtOffset: (CGFloat) offset
{
    UIImageView* dividerImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"CategoryBarDivider"]];
    CGRect dividerFrame = dividerImageView.frame;
    dividerFrame.origin.x = offset;
    dividerImageView.frame = dividerFrame;
    return dividerImageView;
}


- (void) createSubcategoriesTab: (NSSet*) subcategories
{
    // Clean current subviews
    for (UIView* sview in self.secondaryTabsView.subviews)
        [sview removeFromSuperview];
    
    for(SYNCategoryItemView* divider in self.secondaryDividerOverlay.subviews)
        [divider removeFromSuperview];
    
    SYNCategoryItemView* tab = nil;
 
    NSSortDescriptor* idSortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority"
                                                                     ascending: NO];
    
    NSArray* sortedSubcategories = [subcategories sortedArrayUsingDescriptors: [NSArray arrayWithObject: idSortDescriptor]];
        
    for (Subcategory* subcategory in sortedSubcategories)
    {
        tab = [[SYNCategoryItemView alloc] initWithTabItemModel: subcategory];
        [self.secondaryTabsView addSubview: tab];
        
        [tab addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                           action: @selector(handleSecondaryTap:)]];
    }
    [self showSecondaryTabs];
    
    //Layout tabs according to orientation
    [self refreshViewForOrientation: [[UIApplication sharedApplication] statusBarOrientation]];    
}


- (void) showSecondaryTabs
{
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         CGRect secondaryFrame = self.secondaryTabsView.frame;
                         secondaryFrame.origin.y = self.mainTabsView.frame.size.height - 6.0;
                         self.secondaryTabsView.frame = secondaryFrame;
                         self.secondaryTabsBGView.frame = secondaryFrame;
                         self.secondaryDividerOverlay.frame = secondaryFrame;
                     }
                     completion:^(BOOL result){
                         
                     }];
}


- (void) hideSecondaryTabs
{
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         CGRect secondaryFrame = self.secondaryTabsView.frame;
                         secondaryFrame.origin.y = 0.0;
                         self.secondaryTabsView.frame = secondaryFrame;
                         self.secondaryTabsBGView.frame = secondaryFrame;
                         self.secondaryDividerOverlay.frame = secondaryFrame;
                     }
                     completion:^(BOOL result){
                         
                     }];
}


#pragma mark - Delegate Methods

- (void) homeButtonPressed
{
//    for (SYNCategoryItemView* itemView in self.mainTabsView.subviews)
//        [itemView makeFaded];
    
    [self hideSecondaryTabs];
    
    [self.tapDelegate handleMainTap: nil];
}


- (void) handleMainTap: (UITapGestureRecognizer*) recogniser
{
    // Set as pressed
    SYNCategoryItemView* itemView;
    
    for(SYNCategoryItemView* itemView in self.mainTabsView.subviews)
        [itemView makeFaded];
    
    itemView = (SYNCategoryItemView*)recogniser.view;
    [itemView makeHighlighted];
    
    
    // tapDelegate is the SYNCategoryViewController
    [self.tapDelegate handleMainTap: recogniser];
}


- (void) handleSecondaryTap: (UITapGestureRecognizer*) recogniser
{
    SYNCategoryItemView* itemView;
    
    for(SYNCategoryItemView* itemView in self.secondaryTabsView.subviews)
        [itemView makeStandard];
    
    itemView = (SYNCategoryItemView*)recogniser.view;
    [itemView makeHighlighted];
    
    [self.tapDelegate handleSecondaryTap: recogniser];
}


- (void) refreshViewForOrientation: (UIInterfaceOrientation) orientation
{
    //Layout Main tabs
    
    [[self.dividerOverlayView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
    CGFloat nextOrigin = 0;
    
    if (self.useHomeButton == TRUE)
    {
        nextOrigin += self.homeButton.frame.size.width;
        [self.dividerOverlayView addSubview: [self createDividerAtOffset: nextOrigin]];
    }
    
    for (SYNCategoryItemView* tab in [self.mainTabsView subviews])
    {
        [tab resizeForOrientation: orientation
                       withHeight: self.mainTabsView.frame.size.height];
        
        CGRect tabFrame = tab.frame;
        tabFrame.origin.x = nextOrigin;
        tab.frame = tabFrame;        
        nextOrigin += tabFrame.size.width;
        
        [self.dividerOverlayView addSubview: [self createDividerAtOffset: nextOrigin]];
    }
    
    //Layout secondary tabs
    
    [[self.secondaryDividerOverlay subviews]
     makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    nextOrigin = 0.0f;
    CGFloat midSecondaryFrame = self.secondaryTabsView.frame.size.height * 0.5;
    
    for (SYNCategoryItemView* tab in [self.secondaryTabsView subviews])
    {
        [tab resizeForOrientation: orientation
                       withHeight: self.secondaryTabsView.frame.size.height -1.0f];
        
        CGRect tabFrame = tab.frame;
        tabFrame.origin.x = nextOrigin;
        tab.frame = tabFrame;
        nextOrigin += tabFrame.size.width;
        UIImageView* dividerImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"SubCategoryBarDivider"]];
        dividerImageView.center = CGPointMake(nextOrigin, midSecondaryFrame);
        
        [self.secondaryDividerOverlay addSubview: dividerImageView];        
    }
}

@end
