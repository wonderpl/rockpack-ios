//
//  SYNChannelsTopTabViewController.h
//  rockpack
//
//  Created by Nick Banks on 01/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNChannelFooterMoreView.h"

@interface SYNChannelsRootViewController : SYNAbstractViewController
{
    @protected
    NSMutableArray* channels;
}

@property (nonatomic, strong) UICollectionViewController *channelCollectionViewController;
@property (nonatomic, assign) BOOL enableCategoryTable;

- (void) superArcMenuUpdateState: (UIGestureRecognizer *) recognizer;

@end
