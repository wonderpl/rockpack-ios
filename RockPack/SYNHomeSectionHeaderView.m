//
//  SYNHomeSectionHeaderView.m
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "UIFont+SYNFont.h"
#import "SYNHomeSectionHeaderView.h"

@interface SYNHomeSectionHeaderView ()

@property (nonatomic, strong) IBOutlet UIImageView *highlightedSectionView;
@property (nonatomic, strong) IBOutlet UIImageView *sectionView;

@end

@implementation SYNHomeSectionHeaderView

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNHomeSectionHeaderView"
                                                              owner: self
                                                            options: nil];
        
        if ([arrayOfViews count] < 1)
        {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex: 0] isKindOfClass: [UICollectionViewCell class]])
        {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex: 0];
    }
    
    return self;
}


- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.sectionTitleLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.highlightedSectionView.hidden = TRUE;
    self.sectionView.hidden = FALSE;
}


- (void) setFocus: (BOOL) focus
{
    if (focus)
    {
        self.highlightedSectionView.hidden = FALSE;
        self.sectionView.hidden = TRUE;
    }
    else
    {
        self.highlightedSectionView.hidden = TRUE;
        self.sectionView.hidden = FALSE;
    }
}

@end

