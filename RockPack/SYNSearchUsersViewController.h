//
//  SYNSearchUsersViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 08/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNUsersViewController.h"

@class SYNSearchRootViewController;
@class SYNSearchTabView;

@interface SYNSearchUsersViewController : SYNUsersViewController


@property (nonatomic, weak) SYNSearchRootViewController* parent;
@property (nonatomic, weak) SYNSearchTabView* itemToUpdate;

- (void) performNewSearchWithTerm: (NSString*) term;

@end
