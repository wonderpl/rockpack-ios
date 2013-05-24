//
//  SYNCoverRightMoreView.h
//  rockpack
//
//  Created by Nick Banks on 22/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNCoverRightMoreView : UICollectionReusableView

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicatorView;
@property (nonatomic, strong) IBOutlet UILabel *loadingLabel;

@end
