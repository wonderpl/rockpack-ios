//
//  SYNAbstractChannelsDetailViewController.h
//  rockpack
//
//  Created by Nick Banks on 17/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "LXReorderableCollectionViewFlowLayout.h"
#import "SYNAbstractViewController.h"

typedef enum {
    kChannelDetailsModeDisplay = 0,
    kChannelDetailsModeEdit = 1
} kChannelDetailsMode;

@interface SYNChannelDetailViewController : SYNAbstractViewController <LXReorderableCollectionViewDelegateFlowLayout,
                                                                     UICollectionViewDataSource,
                                                                     UICollectionViewDelegateFlowLayout>

- (id) initWithChannel: (Channel *) channel
             usingMode: (kChannelDetailsMode) mode;

@property (nonatomic, assign) kChannelDetailsMode mode;

/**
 If set the channel will automatically play the video on view did load, or when the collection is updated depending on if the video ID
 is present in the channels's video set. Once played, this variabel is set to nil.
*/
@property (nonatomic, strong) NSString* autoplayVideoId;

//FIXME: FAVOURITES Part of workaound for missing favourites functionality. Remove once final solution implemented.
-(BOOL) isFavouritesChannel;
-(void)refreshFavouritesChannel;
@end
