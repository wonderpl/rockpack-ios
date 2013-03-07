//
//  SYNSearchTabView.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNTabView.h"
#import "SYNSearchItemView.h"

@interface SYNSearchTabView : SYNTabView


@property (nonatomic, readonly) SYNSearchItemView* searchVideosItemView;
@property (nonatomic, readonly) SYNSearchItemView* searchChannelsItemView;

@end
