//
//  SYNUserTabView.m
//  rockpack
//
//  Created by Michael Michailidis on 26/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNUserTabView.h"
#import "SYNSearchItemView.h"
#import "AppConstants.h"
#import "UIFont+SYNFont.h"

@interface SYNUserTabView ()


@property (nonatomic, strong) UIView* mainTabsView;
@property (nonatomic, strong) UIView* overlayView;
@property (nonatomic, strong) SYNSearchItemView* channelsItemView;
@property (nonatomic, strong) SYNSearchItemView* followingItemView;
@property (nonatomic, strong) SYNSearchItemView* followersItemView;
@property (nonatomic, strong) UILabel* usernameLabel;

@property (nonatomic, strong) UIImageView* profileImageView;
@property (nonatomic, strong) UILabel* profileNameLabel;

@end

@implementation SYNUserTabView


-(id)initWithSize:(CGFloat)totalWidth
{
    
    if (self = [super init]) {
        
        // == Main Holder Views == //
        
        UIImage* mainTabsBGImage = [UIImage imageNamed:@"BarProfile.png"]; // 140 height
        CGRect mainFrame = CGRectMake(0.0, 0.0, totalWidth, mainTabsBGImage.size.height - 7.0);
        
        self.mainTabsView = [[UIView alloc] initWithFrame:mainFrame];
        self.mainTabsView. backgroundColor = [UIColor colorWithPatternImage:mainTabsBGImage];
        
        self.frame = CGRectMake(0.0, 0.0, totalWidth, mainFrame.size.height);
        
        self.overlayView = [[UIView alloc] initWithFrame:mainFrame];
        self.overlayView.backgroundColor = [UIColor clearColor];
        
        UIView* dividerView = [[UIView alloc] initWithFrame:self.frame];
        dividerView.userInteractionEnabled = NO;
        
        
        
        CGRect itemFrame = CGRectMake(0.0, 0.0, kSearchBarItemWidth, 80.0);
        
        // == Username == //
        
        UIFont* rockpackBoldFont = [UIFont boldRockpackFontOfSize:22.0];
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(160.0, 0.0, 300.0, 80.0)];
        self.usernameLabel.font = rockpackBoldFont;
        self.usernameLabel.textAlignment = NSTextAlignmentLeft;
        self.usernameLabel.backgroundColor = [UIColor clearColor];
        self.usernameLabel.text = @"Kish Patel";
        self.usernameLabel.textColor = [UIColor whiteColor];
        [self.overlayView addSubview:self.usernameLabel];
        
        
        // == Channels Tab == //
        
        self.channelsItemView = [[SYNSearchItemView alloc] initWithTitle:@"CHANNELS" andFrame:itemFrame];
        
        [self.channelsItemView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)]];
        
        
        
        // == Following Tab == //
        
        self.followingItemView = [[SYNSearchItemView alloc] initWithTitle:@"FOLLOWING" andFrame:itemFrame];
        
        [self.followingItemView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)]];
        
        
        
        // == Followers Tab == //
        
        self.followersItemView = [[SYNSearchItemView alloc] initWithTitle:@"FOLLOWERS" andFrame:itemFrame];
        
        [self.followersItemView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)]];
        
        
        
        // == Account Settings == //
        
        
        UIButton* cogImageButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* cogImage = [UIImage imageNamed:@"ButtonSettingsDefault.png"];
        cogImageButton.frame = CGRectMake(0.0, 0.0, cogImage.size.width, cogImage.size.height);
        [cogImageButton setImage:cogImage forState:UIControlStateNormal];
        [cogImageButton setImage:[UIImage imageNamed:@"ButtonSettingsHighlighted.png"] forState:UIControlStateHighlighted];
        [cogImageButton addTarget:self action:@selector(pressedCogButton:) forControlEvents:UIControlEventTouchUpInside];
        cogImageButton.center = CGPointMake(170.0, 90.0);
        [self.overlayView addSubview:cogImageButton];
        
        
        NSString* accountSettingsString = @"ACCOUNT SETTINGS";
        UIFont* rockpackFont = [UIFont rockpackFontOfSize:16];
        CGSize acRect = [accountSettingsString sizeWithFont:rockpackFont];
        UILabel* accountSettingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, acRect.width, acRect.height)];
        accountSettingsLabel.center = CGPointMake(cogImageButton.center.x + 100.0, cogImageButton.center.y + 5.0);
        
        accountSettingsLabel.font = rockpackFont;
        accountSettingsLabel.textAlignment = NSTextAlignmentLeft;
        accountSettingsLabel.backgroundColor = [UIColor clearColor];
        accountSettingsLabel.text = accountSettingsString;
        accountSettingsLabel.textColor = [UIColor whiteColor];
        [self.overlayView addSubview:accountSettingsLabel];
        
        
        
        // == Place Correclty == //
        
        NSArray* tabsToPlace = @[self.channelsItemView, self.followersItemView, self.followingItemView];
        
        CGFloat currentX = (self.frame.size.width * 0.5) - (itemFrame.size.width * 1.5);
        CGFloat halfOffset = itemFrame.size.width * 0.5;
      
        for (SYNSearchItemView* itemTab in tabsToPlace)
        {
            UIImageView* dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchTabDividerHeader.png"]];
            
            CGFloat itemY = self.frame.size.height - itemTab.frame.size.height * 0.5;
            dividerImageView.center = CGPointMake(currentX, itemY);
            
            [dividerView addSubview:dividerImageView];
            
            
            itemTab.center = CGPointMake(currentX + halfOffset, itemY);
            
            [self.mainTabsView addSubview:itemTab];
            
            currentX += halfOffset * 2;
            
        }
        
        // == Profile Pic and Name == //
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 133.0, 133.0)];
        self.profileImageView.image = [UIImage imageNamed:@"AvatarKish.png"];
        [self.overlayView addSubview:self.profileImageView];
        
        
        
        
        [self addSubview:self.mainTabsView];
        [self addSubview:dividerView];
        [self addSubview:self.overlayView];
        
        
        
        
        
        
    }
    
    
    return self;
}

-(void)pressedCogButton:(UIButton*)button
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAccountSettingsPressed
                                                        object:self];
}

-(void)setUser:(User*)user
{
    
    self.usernameLabel.text = user.username;
}


@end
