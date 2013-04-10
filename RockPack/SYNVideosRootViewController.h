//
//  SYNDiscoverTopTabViewController.h
//  RockPack
//
//  Created by Nick Banks on 16/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNLargeVideoPanelViewController.h"

@interface SYNVideosRootViewController : SYNAbstractViewController


@property (nonatomic, strong) NSIndexPath *currentIndexPath;


@property (nonatomic, strong) UIView *largeVideoPanelView;

- (void) setLargeVideoToIndexPath: (NSIndexPath *) indexPath ;

@end
