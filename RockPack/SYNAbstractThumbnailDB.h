//
//  SYNAbstractThumbnailDB.h
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNAbstractThumbnailDB : NSObject

// Properties

@property (nonatomic, strong) NSArray *thumbnailDetailsArray;

// Methods

- (int) numberOfThumbnails;

- (NSString *) keyframeURLForIndex: (int) index
                        withOffset: (int) offset;

- (int) adjustedIndexForIndex: (int) index
                   withOffset: (int) offset;

- (UIImage *) thumbnailForIndex: (int) index
                     withOffset: (int) offset;

- (NSString *) titleForIndex: (int) index
                  withOffset: (int) offset;

- (NSString *) subtitleForIndex: (int) index
                     withOffset: (int) offset;


- (int) rockItNumberForIndex: (int) index
                  withOffset: (int) offset;

- (void) setRockItNumber: (int) number
                forIndex: (int) index
              withOffset: (int) offset;

- (BOOL) rockItForIndex: (int) index
             withOffset: (int) offset;

- (void) setRockIt: (BOOL) number
          forIndex: (int) index
        withOffset: (int) offset;

@end
