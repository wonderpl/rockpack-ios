//
//  SYNSearchTabView.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchTabView.h"
#import "SYNSearchItemView.h"

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
        UIImage* mainTabsBGImage = [UIImage imageNamed:@"TabTop.png"];
        CGRect mainFrame = CGRectMake(0.0, 0.0, totalWidth, mainTabsBGImage.size.height);
        self.mainTabsView = [[UIView alloc] initWithFrame:mainFrame];
        self.mainTabsView. backgroundColor = [UIColor colorWithPatternImage:mainTabsBGImage];
        
        self.frame = CGRectMake(0.0, 0.0, totalWidth, mainFrame.size.height);
        
        
        // Create Search Tab
        self.searchVideosItemView = [[SYNSearchItemView alloc] initWithTitle:@"VIDEOS" andFrame:CGRectMake(0.0, 0.0, 100.0, self.frame.size.height)];
        
        self.searchChannelsItemView = [[SYNSearchItemView alloc] initWithTitle:@"CHANNELS" andFrame:CGRectMake(0.0, 0.0, 100.0, self.frame.size.height)];
        
    }
    return self;
}



@end
