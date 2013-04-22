//
//  SYNSearchRootViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#import "SYNFeedRootViewController.h"

@class SYNSearchTabView;
@class SYNSearchRootViewController;

@interface SYNSearchVideosViewController : SYNFeedRootViewController

@property (nonatomic, weak) SYNSearchRootViewController* parent;
@property (nonatomic, weak) SYNSearchTabView* itemToUpdate;

-(void)performSearchWithTerm:(NSString*)term;

@end
