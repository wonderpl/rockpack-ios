//
//  SYNHomeSectionHeaderView.h
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNHomeSectionHeaderView : UICollectionReusableView

@property (nonatomic, strong) IBOutlet UILabel *sectionTitleLabel;

- (void) setHighlighted: (BOOL) highlighted;

@end
