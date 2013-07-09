//
//  SYNUsersViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 09/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"

@interface SYNUsersViewController : SYNAbstractViewController

@property (nonatomic, strong) UICollectionView* usersThumbnailCollectionView;

@property (nonatomic, strong) NSArray* users;

@property (nonatomic) CGFloat offsetTop;

@end
