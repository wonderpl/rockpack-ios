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

- (int) adjustedIndexForIndex: (int) index
                   withOffset: (int) offset;

- (UIImage *) thumbnailForIndex: (int) index
                     withOffset: (int) offset;

- (NSString *) titleForIndex: (int) index
                  withOffset: (int) offset;

- (NSString *) subtitleForIndex: (int) index
                     withOffset: (int) offset;

- (int) packItNumberForIndex: (int) index
                  withOffset: (int) offset;

- (void) setPackItNumber: (int) number
                forIndex: (int) index
              withOffset: (int) offset;

- (BOOL) packItForIndex: (int) index
             withOffset: (int) offset;

- (void) setPackIt: (BOOL) number
          forIndex: (int) index
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
