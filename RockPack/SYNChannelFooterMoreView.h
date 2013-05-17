//
//  SYNChannelFooterMoreView.h
//  rockpack
//
//  Created by Michael Michailidis on 04/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNChannelFooterMoreView : UICollectionReusableView

@property (nonatomic, strong) IBOutlet UIButton* loadMoreButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (nonatomic) BOOL showsLoading;

@end
