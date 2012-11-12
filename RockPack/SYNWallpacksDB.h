//
//  SYNWallpacksDB.h
//  rockpack
//
//  Created by Nick Banks on 12/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAbstractThumbnailDB.h"

@interface SYNWallpacksDB : SYNAbstractThumbnailDB

+ (id) sharedWallpacksDBManager;

- (NSString *) priceForIndex: (int) index
                  withOffset: (int) offset;

@end
