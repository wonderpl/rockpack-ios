//
//  SYNChannelsDB.h
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNAbstractThumbnailDB.h"

@interface SYNChannelsDB : SYNAbstractThumbnailDB

+ (id) sharedChannelsDBManager;

@end
