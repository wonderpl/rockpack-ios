//
//  SYNDiscoverTopTabViewController.h
//  RockPack
//
//  Created by Nick Banks on 16/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAbstractTopTabViewController.h"

@interface SYNVideosRootViewController : SYNAbstractTopTabViewController 


@property (nonatomic, strong) NSIndexPath *currentIndexPath;


@property (nonatomic, strong) IBOutlet UIView *largeVideoPanelView;

- (void) setLargeVideoToIndexPath: (NSIndexPath *) indexPath ;

@end
