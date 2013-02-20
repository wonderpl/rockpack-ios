//
//  SYNSearchTabView.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchTabView.h"
#import "SYNSearchItemView.h"

#define kSearchBarItemWidth 100.0

@interface SYNSearchTabView ()

@property (nonatomic, strong) UIView* mainTabsView;
@property (nonatomic, strong) SYNSearchItemView* searchVideosItemView;
@property (nonatomic, strong) SYNSearchItemView* searchChannelsItemView;

@end

@implementation SYNSearchTabView

-(id)initWithSize:(CGFloat)totalWidth
{
    
    if (self = [super init]) {
        
        // Main Bar //
        
        UIImage* mainTabsBGImage = [UIImage imageNamed:@"SearchTabPanelHeader.png"];
        CGRect mainFrame = CGRectMake(0.0, 0.0, totalWidth, mainTabsBGImage.size.height);
        self.mainTabsView = [[UIView alloc] initWithFrame:mainFrame];
        self.mainTabsView. backgroundColor = [UIColor colorWithPatternImage:mainTabsBGImage];
        
        self.frame = CGRectMake(0.0, 0.0, totalWidth, mainFrame.size.height);
        
        CGFloat midBar = self.frame.size.width * 0.5;
        
        
        UIView* dividerView = [[UIView alloc] initWithFrame:self.frame];
        
        
        NSArray* itemsX = @[[NSNumber numberWithFloat:(midBar - kSearchBarItemWidth)],
                            [NSNumber numberWithFloat:midBar],
                            [NSNumber numberWithFloat:(midBar + kSearchBarItemWidth)]];
        
        for (NSNumber* itemX in itemsX)
        {
            UIImageView* dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchTabDividerHeader.png"]];
            dividerImageView.center = CGPointMake([itemX floatValue], self.center.y);
            [dividerView addSubview:dividerImageView];
            
        }
        
        // Create Search Tab
        self.searchVideosItemView = [[SYNSearchItemView alloc] initWithTitle:@"VIDEOS" andFrame:CGRectMake(midBar - kSearchBarItemWidth, 0.0, kSearchBarItemWidth, self.frame.size.height)];
        
        self.searchChannelsItemView = [[SYNSearchItemView alloc] initWithTitle:@"CHANNELS" andFrame:CGRectMake(midBar, 0.0, kSearchBarItemWidth, self.frame.size.height)];
        
        
        // Create dividers
        
        
        
        
        
        [self addSubview:self.mainTabsView];
        [self addSubview:dividerView];
        
    }
    return self;
}



@end
