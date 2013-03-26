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
#import "SYNAppDelegate.h"
#import "User.h"
#import "UIColor+SYNColor.h"
#import "SYNUserItemView.h"

@interface SYNUserTabView ()


@property (nonatomic, strong) UIView* mainTabsView;
@property (nonatomic, strong) UIView* overlayView;
@property (nonatomic, strong) SYNUserItemView* channelsItemView;
@property (nonatomic, strong) SYNUserItemView* followingItemView;
@property (nonatomic, strong) SYNUserItemView* followersItemView;
@property (nonatomic, strong) UILabel* fullnameLabel;
@property (nonatomic, strong) UILabel* usernameLabel;
@property (nonatomic, strong) UIImageView* profileImageView;
@property (nonatomic, strong) UILabel* profileNameLabel;
@property (nonatomic, weak) SYNSearchItemView* currentItemView;
@property (nonatomic, weak) User* user;
@property (nonatomic, strong) NSMutableArray* tabItems;

@end

@implementation SYNUserTabView

@synthesize tabItems;

-(id)initWithSize:(CGFloat)totalWidth
{
    
    if (self = [super init]) {
        
        // == Main Holder Views == //
        
        SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.user = appDelegate.currentUser;
        
        UIImage* mainTabsBGImage = [UIImage imageNamed:@"BarHeaderYou.png"]; // 121 height
        CGRect mainFrame = CGRectMake(0.0, 0.0, totalWidth, mainTabsBGImage.size.height);
        
        self.mainTabsView = [[UIView alloc] initWithFrame:mainFrame];
        self.mainTabsView. backgroundColor = [UIColor colorWithPatternImage:mainTabsBGImage];
        
        self.frame = CGRectMake(0.0, 0.0, totalWidth, mainFrame.size.height);
        
        self.overlayView = [[UIView alloc] initWithFrame:mainFrame];
        self.overlayView.backgroundColor = [UIColor clearColor];
        self.overlayView.userInteractionEnabled = NO;
        
        UIView* dividerView = [[UIView alloc] initWithFrame:self.frame];
        dividerView.userInteractionEnabled = NO;
        
        tabItems = [[NSMutableArray alloc] initWithCapacity:3];
        
        CGRect itemFrame = CGRectMake(0.0, 0.0, kSearchBarItemWidth, self.frame.size.height);
        
        
        // == Full Name == //
        
        UIFont* rockpackBoldFont = [UIFont boldRockpackFontOfSize:28.0];
        NSString* nameString;
        if(self.user.firstName && self.user.lastName && ![self.user.firstName isEqualToString:@""] && ![self.user.lastName isEqualToString:@""])
            nameString = [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];
        else
            nameString = @"FULL NAME";
        
        CGSize sizeOfNameLabel = [nameString sizeWithFont:rockpackBoldFont];
        CGRect nameRect = CGRectIntegral(CGRectMake(132.0, 34.0, 450.0, sizeOfNameLabel.height));
        self.fullnameLabel = [[UILabel alloc] initWithFrame:nameRect];
        self.fullnameLabel.font = rockpackBoldFont;
        self.fullnameLabel.textAlignment = NSTextAlignmentLeft;
        self.fullnameLabel.backgroundColor = [UIColor clearColor];
        
        nameString = [nameString uppercaseString];
        self.fullnameLabel.text = nameString;
        self.fullnameLabel.textColor = [UIColor whiteColor];
        [self.overlayView addSubview:self.fullnameLabel];
        
        
        // == Username == //
        // Kish says: Username position/size is no longer dependant on Fullname as Fullname can be longer than
        // username. Also it was messing with the position of the flag button.
        UIFont* usernameFont = [UIFont rockpackFontOfSize:16.0];
        NSString* usernameString;
        if(self.user.username && ![self.user.username isEqualToString:@""])
            usernameString = [self.user.username uppercaseString];
        else
            usernameString = @"THEKISHPATEL91";
        
        CGSize usernameStringSize = [usernameString sizeWithFont:usernameFont];
        CGRect usernameRect = CGRectIntegral(CGRectMake(132.0, 66.0, usernameStringSize.width, usernameStringSize.height));
        self.usernameLabel = [[UILabel alloc] initWithFrame:usernameRect];
        self.usernameLabel.font = usernameFont;
        self.usernameLabel.textAlignment = NSTextAlignmentLeft;
        self.usernameLabel.backgroundColor = [UIColor clearColor];
        self.usernameLabel.text = usernameString;
        self.usernameLabel.textColor = [UIColor rockpackHeaderSubtitleColor];
        self.usernameLabel.frame = usernameRect;
        [self.overlayView addSubview:self.usernameLabel];
        
        
        // Flag
        
        UIImage* flagImage = [UIImage imageNamed:@"ButtonFlagDefault.png"];
        UIButton* flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        flagButton.frame = CGRectMake(self.usernameLabel.frame.origin.x + self.usernameLabel.frame.size.width + 10.0,
                                      self.usernameLabel.frame.origin.y - 6.0,
                                      flagImage.size.width, flagImage.size.height);
        
        [flagButton setImage:flagImage forState:UIControlStateNormal];
        [flagButton setImage:[UIImage imageNamed:@"ButtonFlagHighlighted.png"] forState:UIControlStateHighlighted];
        [self.overlayView addSubview:flagButton];
        
        
        // == Channels Tab == //
        
        self.channelsItemView = [[SYNUserItemView alloc] initWithTitle:@"CHANNELS" andFrame:itemFrame];
        
        [self.channelsItemView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)]];
        
        
        
        // == Following Tab == //
        
        self.followingItemView = [[SYNUserItemView alloc] initWithTitle:@"FOLLOWING" andFrame:itemFrame];
        
        [self.followingItemView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)]];
        
        
        
        // == Followers Tab == //
        
        self.followersItemView = [[SYNUserItemView alloc] initWithTitle:@"FOLLOWERS" andFrame:itemFrame];
        
        [self.followersItemView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)]];
        
        
        // == Temporary fix: Divider at end of Tabs == //
        
        UIImageView *endDividerYouImage = [[UIImageView alloc] initWithFrame:CGRectMake(1014.0, 0.0, 2.0, 115.0)];
                                    UIImage *image = [UIImage imageNamed:@"DividerYou.png"];
                                    endDividerYouImage.image = image;
        [self.overlayView addSubview:endDividerYouImage];
        
        
        // == Account Settings == //
        
        
        UIButton* cogImageButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* cogImage = [UIImage imageNamed:@"ButtonSettingsDefault.png"];
        cogImageButton.frame = CGRectMake(0.0, 0.0, cogImage.size.width, cogImage.size.height);
        [cogImageButton setImage:cogImage forState:UIControlStateNormal];
        [cogImageButton setImage:[UIImage imageNamed:@"ButtonSettingsHighlighted.png"] forState:UIControlStateHighlighted];
        [cogImageButton addTarget:self action:@selector(pressedCogButton:) forControlEvents:UIControlEventTouchUpInside];
        cogImageButton.center = CGPointMake(676.0, 57.0);
        cogImageButton.frame = CGRectIntegral(cogImageButton.frame);
        [self.mainTabsView addSubview:cogImageButton];
        
        
        
        // == Place Correclty == //
        
        NSArray* tabsToPlace = @[self.channelsItemView, self.followingItemView, self.followersItemView];
        
        CGFloat currentX = 716.0;
        CGFloat halfOffset = itemFrame.size.width * 0.5;
      
        for (SYNSearchItemView* itemTab in tabsToPlace)
        {
            UIImageView* dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DividerYou.png"]];
            
            //Mike's maths
            //CGFloat itemY = self.frame.size.height - itemTab.frame.size.height * 0.5;
            
            //Kish's Absolute
            CGFloat itemY = 57.0;

            
            dividerImageView.center = CGPointMake(currentX, itemY);
            dividerImageView.frame = CGRectIntegral(dividerImageView.frame);
            [dividerView addSubview:dividerImageView];
            
            
            itemTab.center = CGPointMake(currentX + halfOffset, itemY);
            
            itemTab.frame = CGRectIntegral(itemTab.frame);
            
            
            [itemTab addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)]];
            
            [tabItems addObject:itemTab];
            
            [self.mainTabsView addSubview:itemTab];
            
            currentX += halfOffset * 2;
            
        }
        
        // == Profile Pic and Name == //
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 114.0, 114.0)];
        self.profileImageView.image = [UIImage imageNamed:@"AvatarKish.png"];
        [self.overlayView addSubview:self.profileImageView];
        
        
        // == Profile Gloss, Shadows & Divider == //
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 116.0, 115.0)];
        self.profileImageView.image = [UIImage imageNamed:@"GlossAvatarProfile.png"];
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
    
    self.fullnameLabel.text = user.username;
}


#pragma mark - Delegate Methods

-(void)handleMainTap:(UITapGestureRecognizer*)recogniser
{
    
    
    SYNSearchItemView* viewClicked = (SYNSearchItemView*)recogniser.view;
    if (self.currentItemView == viewClicked)
        return;
    
    self.currentItemView = viewClicked;
    
    
    NSString* tabTappedId;
    
    if(self.currentItemView == self.channelsItemView)
        tabTappedId = @"0";
    else if(self.currentItemView == self.followingItemView)
        tabTappedId = @"1";
    else
        tabTappedId = @"2";
    
    [self setSelectedWithId:tabTappedId];
    
}

-(void)setSelectedWithId:(NSString*)selectedId
{
    
    for(SYNSearchItemView* itemViewS in tabItems)
        [itemViewS makeFaded];
    
    if([selectedId isEqualToString:@"0"])
        [self.channelsItemView makeHighlightedWithImage:YES];
    else if([selectedId isEqualToString:@"1"])
        [self.followingItemView makeHighlightedWithImage:YES];
    else
        [self.followersItemView makeHighlightedWithImage:YES];
    
    
    [self.tapDelegate handleNewTabSelectionWithId:selectedId];
}

@end
