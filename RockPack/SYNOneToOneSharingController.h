//
//  SYNOneToOneSharingController.h
//  rockpack
//
//  Created by Michael Michailidis on 28/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNOAuthNetworkEngine.h"

@interface SYNOneToOneSharingController : UIViewController

+ (id) withResourceType: (AbstractCommon *) objectToShare andImage: (UIImage *) imageToShare;
- (id) initWithResource: (AbstractCommon *) objectToShare andImage: (UIImage *) imageToShare;

- (IBAction) authorizeFacebookButtonPressed: (id) sender;
- (IBAction) authorizeAddressBookButtonPressed: (id) sender;

@end
