//
//  SYNUserTabView.m
//  rockpack
//
//  Created by Michael Michailidis on 26/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNUserTabView.h"
#import "SYNSearchItemView.h"

@interface SYNUserTabView ()


@property (nonatomic, strong) UIView* mainTabsView;
@property (nonatomic, strong) SYNSearchItemView* channelsItemView;
@property (nonatomic, strong) SYNSearchItemView* followingItemView;
@property (nonatomic, strong) SYNSearchItemView* followersItemView;

@property (nonatomic, strong) UIImageView* profileImageView;
@property (nonatomic, strong) UILabel* profileNameLabel;

@end

@implementation SYNUserTabView


-(id)initWithSize:(CGFloat)totalWidth
{
    
    if (self = [super init]) {
        
        // == Main Holder Views == //
        
        UIImage* mainTabsBGImage = [UIImage imageNamed:@"SearchTabPanelHeader.png"];
        CGRect mainFrame = CGRectMake(0.0, 0.0, totalWidth, mainTabsBGImage.size.height - 7.0);
        
        self.mainTabsView = [[UIView alloc] initWithFrame:mainFrame];
        self.mainTabsView. backgroundColor = [UIColor colorWithPatternImage:mainTabsBGImage];
        
        self.frame = CGRectMake(0.0, 0.0, totalWidth, mainFrame.size.height);
        
        CGFloat midBar = self.frame.size.width * 0.5;
        
        
        UIView* dividerView = [[UIView alloc] initWithFrame:self.frame];
        dividerView.userInteractionEnabled = NO;
        
        
        
        
        
        
        CGRect itemFrame = CGRectMake(0.0, 0.0, 0.0, 0.0);
        
        
        // == Channels Tab == //
        
        self.channelsItemView = [[SYNSearchItemView alloc] initWithTitle:@"CHANNELS" andFrame:itemFrame];
        
        [self.channelsItemView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)]];
        
        [self.mainTabsView addSubview:self.channelsItemView];
        
        
        // == Following Tab == //
        
        self.followingItemView = [[SYNSearchItemView alloc] initWithTitle:@"FOLLOWING" andFrame:itemFrame];
        
        [self.followingItemView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)]];
        
        [self.mainTabsView addSubview:self.followingItemView];
        
        
        // == Followers Tab == //
        
        self.followingItemView = [[SYNSearchItemView alloc] initWithTitle:@"FOLLOWERS" andFrame:itemFrame];
        
        [self.followingItemView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)]];
        
        [self.mainTabsView addSubview:self.followingItemView];
        
        
        // == Place Correclty == //
        
        NSArray* tabsToPlace = @[self.channelsItemView, self.followersItemView, self.followingItemView];
        
        CGFloat currentX = 300.0;
        CGFloat hOffset = itemFrame.size.width * 0.5;
        for (SYNSearchItemView* itemTab in tabsToPlace)
        {
            UIImageView* dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchTabDividerHeader.png"]];
            
            dividerImageView.center = CGPointMake(currentX, self.center.y);
            
            [dividerView addSubview:dividerImageView];
            
            itemTab.center = CGPointMake(currentX + hOffset, self.center.y);
            currentX += hOffset * 2;
            
        }
        
        
        [self addSubview:self.mainTabsView];
        [self addSubview:dividerView];
        
        
        // == Profile Pic and Name == //
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, self.frame.size.height)];
        [self addSubview:self.profileImageView];
        
        self.profileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, self.frame.size.height)];
        [self addSubview:self.profileNameLabel];
        
    }
    return self;
}


-(void)setUser:(User*)user
{
    // TODO: Load image and display it
}


@end
