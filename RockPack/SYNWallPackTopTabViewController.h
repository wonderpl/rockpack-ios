//
//  SYNWallPackTopTabViewController.h
//  rockpack
//
//  Created by Nick Banks on 12/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAbstractTopTabViewController.h"

@interface SYNWallPackTopTabViewController : SYNAbstractTopTabViewController <UICollectionViewDelegate,
                                                                              UICollectionViewDataSource,
                                                                              UIScrollViewDelegate>

- (IBAction) userTouchedBackButton: (id) sender;

@end
