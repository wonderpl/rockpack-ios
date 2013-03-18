//
//  SYNSearchTabView.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchTabView.h"
#import "SYNSwitch.h"
#import "AppConstants.h"

@interface SYNSearchTabView ()

@property (nonatomic, strong) UIView* mainTabsView;

@property (nonatomic, weak) SYNSearchItemView* currentItemView;

@property (nonatomic, strong) SYNSwitch* popularSwitch;
@property (nonatomic, strong) SYNSearchItemView* searchVideosItemView;
@property (nonatomic, strong) SYNSearchItemView* searchChannelsItemView;

@end

@implementation SYNSearchTabView

-(id)initWithSize:(CGFloat)totalWidth
{
    
    if (self = [super init]) {
        
        // Main Bar //
        
        UIImage* mainTabsBGImage = [UIImage imageNamed:@"SearchTabPanelHeader.png"];
        CGRect mainFrame = CGRectMake(0.0, 0.0, totalWidth, mainTabsBGImage.size.height - 7.0);
        
        self.mainTabsView = [[UIView alloc] initWithFrame:mainFrame];
        self.mainTabsView. backgroundColor = [UIColor colorWithPatternImage:mainTabsBGImage];
        
        self.frame = CGRectMake(0.0, 0.0, totalWidth, mainFrame.size.height);
        
        CGFloat midBar = self.frame.size.width * 0.5;
        
        
        UIView* dividerView = [[UIView alloc] initWithFrame:self.frame];
        dividerView.userInteractionEnabled = NO;
        
        
        NSArray* itemsX = @[[NSNumber numberWithFloat:(midBar - kSearchBarItemWidth)],
                            [NSNumber numberWithFloat:midBar],
                            [NSNumber numberWithFloat:(midBar + kSearchBarItemWidth)]];
        
        // Create dividers
        
        for (NSNumber* itemX in itemsX)
        {
            UIImageView* dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchTabDividerHeader.png"]];
            dividerImageView.center = CGPointMake([itemX floatValue], self.center.y);
            [dividerView addSubview:dividerImageView];
            
        }
        
        
        // == Create Search Tab == //
        
        self.searchVideosItemView = [[SYNSearchItemView alloc] initWithTitle:@"VIDEOS"
                                                                    andFrame:CGRectMake(midBar - kSearchBarItemWidth + 1.0,
                                                                                        0.0,
                                                                                        kSearchBarItemWidth - 1.0,
                                                                                        self.frame.size.height)];
        
        [self.searchVideosItemView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)]];
        
        [self.mainTabsView addSubview:self.searchVideosItemView];
        
        
        // == Create Channels Tab == //
        
        self.searchChannelsItemView = [[SYNSearchItemView alloc] initWithTitle:@"CHANNELS"
                                                                      andFrame:CGRectMake(midBar + 1.0, 0.0, kSearchBarItemWidth - 1.0, self.frame.size.height)];
        
        [self.searchChannelsItemView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)]];
        
        
        [self.mainTabsView addSubview:self.searchChannelsItemView];
        
        
        // == Create Switch
        
        self.popularSwitch = [[SYNSwitch alloc] initWithLeftText:@"POPULAR" andRightText:@"LATEST"];
        self.popularSwitch.center = CGPointMake(850.0, 38.0);
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPerformed:)];
        [self.popularSwitch addGestureRecognizer:tapGesture];
        
        UISwipeGestureRecognizer* leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchSwiped:)];
        leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.popularSwitch addGestureRecognizer:leftSwipeGesture];
        
        UISwipeGestureRecognizer* rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchSwiped:)];
        leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.popularSwitch addGestureRecognizer:rightSwipeGesture];
        
        [self addSubview:self.mainTabsView];
        [self addSubview:dividerView];
        
        
        [self addSubview:self.popularSwitch];
        
    }
    return self;
}

-(void)switchSwiped:(UISwipeGestureRecognizer*)recogniser
{
    if(recogniser.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [self.popularSwitch setOn:NO];
    }
    else if(recogniser.direction == UISwipeGestureRecognizerDirectionRight)
    {
        [self.popularSwitch setOn:YES];
    }
}


-(void)tapPerformed:(UITapGestureRecognizer*)recogniser
{
    BOOL currentState = self.popularSwitch.on;
    [self.popularSwitch setOn:!currentState];
    
    
}

#pragma mark - Delegate Methods

-(void)handleMainTap:(UITapGestureRecognizer*)recogniser
{
    // Set as pressed
    
    
    
    SYNSearchItemView* viewClicked = (SYNSearchItemView*)recogniser.view;
    if (self.currentItemView == viewClicked) 
        return;
    
    self.currentItemView = viewClicked;
    
    
    NSString* tabTappedId;
    
    if(self.currentItemView == self.searchVideosItemView)
        tabTappedId = @"0";
    else
        tabTappedId = @"1";
    
    [self setSelectedWithId:tabTappedId];
    
}


-(void)setSelectedWithId:(NSString*)selectedId
{
    
    for(SYNSearchItemView* itemViewS in self.mainTabsView.subviews)
        [itemViewS makeFaded];
    
    if([selectedId isEqualToString:@"0"])
        [self.searchVideosItemView makeHighlightedWithImage:YES];
    else
        [self.searchChannelsItemView makeHighlightedWithImage:YES];
    
    
    [self.tapDelegate handleNewTabSelectionWithId:selectedId];
}


@end
