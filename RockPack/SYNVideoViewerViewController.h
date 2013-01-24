//
//  SYNVideoViewerViewController.h
//  rockpack
//
//  Created by Nick Banks on 23/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoInstance;

@interface SYNVideoViewerViewController : UIViewController

- (id) initWithVideoInstance: (VideoInstance *) videoInstance;

@property (readonly, nonatomic, strong) IBOutlet UIButton *closeButton;

@end
