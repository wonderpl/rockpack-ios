//
//  SYNNoChannelsMessageView.h
//  rockpack
//
//  Created by Kish Patel on 17/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNNoChannelsMessageView : UIView

+ (id) withMessage: (NSString *) message;

- (id) initWithMessage: (NSString*) message;
- (void) setMessage: (NSString*) newMessage;

@end
