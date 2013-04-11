//
//  SYNRefreshButton.h
//  rockpack
//
//  Created by Michael Michailidis on 11/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SYNRefreshButton : UIControl {
    UIImageView* image;
    UIButton* button;
}

- (void) spinRefreshButton: (BOOL) spin;

@end
