//
//  SYNVideoDB.h
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNAbstractThumbnailDB.h"

@interface SYNVideoDB : SYNAbstractThumbnailDB

+ (id) sharedVideoDBManager;

- (NSURL *) videoURLForIndex: (int) index
                  withOffset: (int) offset;

@end
