//
//  SYNVideoViewerViewController.h
//  rockpack
//
//  Created by Nick Banks on 23/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"

@class SYNMasterViewController;

@interface SYNVideoViewerViewController : SYNAbstractViewController

- (id) initWithVideoInstanceArray: (NSArray *) videoInstanceArray
                    selectedIndex: (int) selectedIndex;

@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) SYNMasterViewController *overlayParent;
@property (nonatomic, assign) BOOL shownFromChannelScreen;
@property (nonatomic, strong) IBOutlet UIImageView *iPhonePanelImageView;


- (void) playIfVideoActive;
- (void) pauseIfVideoActive;

// FIXME: FAVOURITES the method below is used as a workaround for missing favouriting/unfavouriting functionality. Must be removed and reworked when favouriting on Video or VideoInstance has been decided.
-(void)markAsFavourites;

@end
