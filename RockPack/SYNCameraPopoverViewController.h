//
//  SYNCameraPopoverViewController.h
//  rockpack
//
//  Created by Nick Banks on 11/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SYNCameraPopoverViewControllerDelegate;

@interface SYNCameraPopoverViewController : UIViewController

@property (nonatomic, weak) id<SYNCameraPopoverViewControllerDelegate> delegate;

@end

@protocol SYNCameraPopoverViewControllerDelegate <NSObject>

- (void) userTouchedTakePhotoButton: (id) sender;
- (void) userTouchedChooseExistingPhotoButton: (id) sender;

@end
