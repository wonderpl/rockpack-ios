//
//  SYNSearchChannelsViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNChannelsRootViewController.h"

@class SYNSearchTabView;
@class SYNSearchRootViewController;

@interface SYNSearchChannelsViewController : SYNChannelsRootViewController


@property (nonatomic, weak) SYNSearchRootViewController* parent;
@property (nonatomic, weak) SYNSearchTabView* itemToUpdate;

- (void) performNewSearchWithTerm: (NSString*) term;

@end
