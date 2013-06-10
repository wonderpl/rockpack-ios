//
//  NSIndexPath+Arithmetic.h
//  rockpack
//
//  Created by Nick Banks on 28/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSFetchedResultsController;

@interface NSIndexPath (Arithmetic)

- (NSIndexPath *) nextIndexPathUsingFetchedResultsController: (NSFetchedResultsController *) fetchedResultsController;
- (NSIndexPath *) previousIndexPathUsingFetchedResultsController: (NSFetchedResultsController *) fetchedResultsController;

@end
