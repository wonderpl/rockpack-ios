//
//  SYNRefreshButton.h
//  rockpack
//
//  Created by Michael Michailidis on 11/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SYNRefreshButton : UIControl

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* spinner;

- (void) startRefreshCycle;
- (void) endRefreshCycle;

+ (id) refreshButton;

@end
