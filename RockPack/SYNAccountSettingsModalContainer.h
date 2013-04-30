//
//  SYNAccountSettingsModalContainer.h
//  rockpack
//
//  Created by Michael Michailidis on 30/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNAccountSettingsModalContainer : UIViewController <UINavigationControllerDelegate> {
    UINavigationController* childNavigationController;
}

-(id)initWithNavigationController:(UINavigationController*)navigationController;

@end
