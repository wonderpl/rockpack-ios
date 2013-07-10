//
//  SYNAbstractVideoPlayer.h
//  rockpack
//
//  Created by Nick Banks on 10/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNAbstractVideoPlayer : NSObject

- (UIWebView *) createWebView;
- (UIWebView *) createVideoWebView;

- (CGFloat) videoWidth;
- (CGFloat) videoHeight;

- (void) handlePlayerEvent: (NSString *) actionName
                 eventData: (NSString *) actionData;

@end
