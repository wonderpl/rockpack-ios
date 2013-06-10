//
//  NSIndexPath+Arithmetic.m
//  rockpack
//
//  Created by Nick Banks on 28/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "NSIndexPath+Arithmetic.h"
#import <CoreData/CoreData.h>

@implementation NSIndexPath (Arithmetic)

- (NSIndexPath *) nextIndexPathUsingFetchedResultsController: (NSFetchedResultsController *) fetchedResultsController
{
    // Get the current number of section and calculate the next one
    int numOfSections = fetchedResultsController.sections.count;
    int nextSection = ((self.section + 1) % numOfSections);
    
    // Get the info for the current section
    id <NSFetchedResultsSectionInfo> sectionInfo = fetchedResultsController.sections[self.section];
    
    // Check to see
    if ((self.item + 1) >= sectionInfo.numberOfObjects)
    {
        // Wrap around to the first item in the next section (which itself may have wrapped around)
        return [NSIndexPath indexPathForRow: 0
                                  inSection: nextSection];
    }
    else
    {
        // Return the next row in the section
        return [NSIndexPath indexPathForRow: self.item + 1
                                  inSection: self.section];
    }
}


- (NSIndexPath *) previousIndexPathUsingFetchedResultsController: (NSFetchedResultsController *) fetchedResultsController
{
    // Get the current number of section and calculate the next one
    int numOfSections = fetchedResultsController.sections.count;
    
    // Calculate the previous section
    int previousSection = self.section - 1;
    
    // Check to see if we need to wrap around
    if (previousSection < 0)
    {
        // Set to the last section
        previousSection = numOfSections - 1;
    }
    
    // Get the info for the current section
    id <NSFetchedResultsSectionInfo> previousSectionInfo = fetchedResultsController.sections[previousSection];
    
    // Check to see if we need to wrap around
    if ((self.item - 1) < 0)
    {
        // Set to the last index of the previous section
        return [NSIndexPath indexPathForRow: previousSectionInfo.numberOfObjects - 1
                                  inSection: previousSection];
    }
    else
    {
        // Set to the previous index in this section
        return [NSIndexPath indexPathForRow: (self.item - 1)
                                  inSection: self.section];
    }
}

@end
