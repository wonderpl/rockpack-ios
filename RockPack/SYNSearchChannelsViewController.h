//
//  SYNSearchChannelsViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelsRootViewController.h"

@class SYNSearchTabView;
@class SYNSearchRootViewController;

@interface SYNSearchChannelsViewController : SYNChannelsRootViewController


@property (nonatomic, weak) SYNSearchRootViewController* parent;
@property (nonatomic, weak) SYNSearchTabView* itemToUpdate;

-(void)performSearchWithTerm:(NSString*)term;

@end
