//
//  SYNFeedMessagesView.h
//  rockpack
//
//  Created by Michael Michailidis on 30/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNFeedMessagesView : UIView


+ (id) withMessage: (NSString*) message;

- (id) initWithMessage: (NSString*) message;

-(void)setMessage:(NSString*)newMessage;

@end
