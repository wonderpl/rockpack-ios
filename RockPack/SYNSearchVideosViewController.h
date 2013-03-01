//
//  SYNSearchRootViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideosRootViewController.h"

@class SYNSearchItemView;

@interface SYNSearchVideosViewController : SYNVideosRootViewController

@property (nonatomic, weak) SYNSearchItemView* itemToUpdate;

-(void)performSearchWithTerm:(NSString*)term;

@end
