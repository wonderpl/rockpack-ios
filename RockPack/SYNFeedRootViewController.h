//
//  SYNHomeTopTabViewController.h
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"

#import "SYNRefreshButton.h"
#import "SYNVideoThumbnailWideCell.h"

@interface SYNFeedRootViewController : SYNAbstractViewController

@property (nonatomic, strong) SYNRefreshButton* refreshButton;
@property (nonatomic, strong) NSFetchRequest* fetchRequest;
@property (nonatomic, strong) NSArray* resultArray;
@property (nonatomic, weak) SYNVideoThumbnailWideCell* selectedCell;

- (void) removeEmptyGenreMessage;
- (void) displayEmptyGenreMessage: (NSString*) messageKey
                        andLoader: (BOOL) isLoader;



@end
