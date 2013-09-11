//
//  SYNRefreshButton.h
//  rockpack
//
//  Created by Michael Michailidis on 11/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SYNRefreshControl : UIControl {
    UIImageView* iconImageView;
}

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* spinner;

- (void) start;
- (void) stop;

+ (id) refreshControl;

@end
