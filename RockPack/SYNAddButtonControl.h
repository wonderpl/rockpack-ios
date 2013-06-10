//
//  SYNAddButtonControl.h
//  rockpack
//
//  Created by Michael Michailidis on 16/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYNAppDelegate;

@interface SYNAddButtonControl : UIControl {
    UIButton* button;
    __weak SYNAppDelegate* appDelegate;
    UIImage* buttonImageInactive;
    UIImage* buttonImageInactiveHighlighted;
    UIImage* buttonImageActive;
    UIImage* buttonImageActiveHighlighted;
    
}

@property (nonatomic) BOOL active;

+(id)button;

@end
