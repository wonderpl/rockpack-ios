//
//  SYNAbstractThumbnailDB.m
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAbstractThumbnailDB.h"

@interface SYNAbstractThumbnailDB ()

@end

@implementation SYNAbstractThumbnailDB

- (int) numberOfThumbnails
{
    return self.thumbnailDetailsArray.count;
}


// We will need to wrap around

- (int) adjustedIndexForIndex: (int) index
                   withOffset: (int) offset
{
    return (index + offset) % self.thumbnailDetailsArray.count;
}


// The thumbnail itself

- (UIImage *) thumbnailForIndex: (int) index
                     withOffset: (int) offset
{
    NSDictionary *videoDetails = [self.thumbnailDetailsArray objectAtIndex: [self adjustedIndexForIndex: index withOffset: offset]];
    NSString *thumbnailString = [videoDetails objectForKey: @"thumbnail"];
    
    UIImage *thumbnail = [UIImage imageNamed: thumbnailString];
    return thumbnail;
}

- (NSString *) keyframeURLForIndex: (int) index
                     withOffset: (int) offset
{
    NSDictionary *videoDetails = [self.thumbnailDetailsArray objectAtIndex: [self adjustedIndexForIndex: index withOffset: offset]];
    return [videoDetails objectForKey: @"thumbnail"];
}

// Title accessor

- (NSString *) titleForIndex: (int) index
                  withOffset: (int) offset
{
    NSDictionary *videoDetails = [self.thumbnailDetailsArray objectAtIndex: [self adjustedIndexForIndex: index withOffset: offset]];
    NSString *videoTitle = [videoDetails objectForKey: @"title"];
    
    return videoTitle;
}


// Subtitle accessor

- (NSString *) subtitleForIndex: (int) index
                     withOffset: (int) offset
{
    NSDictionary *videoDetails = [self.thumbnailDetailsArray objectAtIndex: [self adjustedIndexForIndex: index withOffset: offset]];
    NSString *videoTitle = [videoDetails objectForKey: @"subtitle"];
    
    return videoTitle;
}



// PackIt accessors

- (int) packItNumberForIndex: (int) index
                  withOffset: (int) offset
{
    NSMutableDictionary *videoDetails = [self.thumbnailDetailsArray objectAtIndex: [self adjustedIndexForIndex: index withOffset: offset]];
    
    int packItNumber = [(NSNumber *)[videoDetails objectForKey: @"packItNumber"] intValue];
    
    return packItNumber;
}


- (void) setPackItNumber: (int) number
                forIndex: (int) index
              withOffset: (int) offset
{
    NSMutableDictionary *videoDetails = [self.thumbnailDetailsArray objectAtIndex: [self adjustedIndexForIndex: index withOffset: offset]];
    
    [videoDetails setObject: [NSNumber numberWithInt: number]
                     forKey: @"packItNumber"];
    
}


- (BOOL) packItForIndex: (int) index
             withOffset: (int) offset
{
    NSMutableDictionary *videoDetails = [self.thumbnailDetailsArray objectAtIndex: [self adjustedIndexForIndex: index withOffset: offset]];
    
    BOOL packIt = [(NSNumber *)[videoDetails objectForKey: @"packIt"] intValue];
    
    return packIt;
}


- (void) setPackIt: (BOOL) number
          forIndex: (int) index
        withOffset: (int) offset
{
    NSMutableDictionary *videoDetails = [self.thumbnailDetailsArray objectAtIndex: [self adjustedIndexForIndex: index withOffset: offset]];
    
    [videoDetails setObject: [NSNumber numberWithInt: number]
                     forKey: @"packIt"];
    
}

// RockIt accessors

- (int) rockItNumberForIndex: (int) index
                  withOffset: (int) offset
{
    NSMutableDictionary *videoDetails = [self.thumbnailDetailsArray objectAtIndex: [self adjustedIndexForIndex: index withOffset: offset]];
    
    int packItNumber = [(NSNumber *)[videoDetails objectForKey: @"rockItNumber"] intValue];
    
    return packItNumber;
}


- (void) setRockItNumber: (int) number
                forIndex: (int) index
              withOffset: (int) offset
{
    NSMutableDictionary *videoDetails = [self.thumbnailDetailsArray objectAtIndex: [self adjustedIndexForIndex: index withOffset: offset]];
    
    [videoDetails setObject: [NSNumber numberWithInt: number]
                     forKey: @"rockItNumber"];
    
}

- (BOOL) rockItForIndex: (int) index
             withOffset: (int) offset
{
    NSMutableDictionary *videoDetails = [self.thumbnailDetailsArray objectAtIndex: [self adjustedIndexForIndex: index withOffset: offset]];
    
    BOOL packItNumber = [(NSNumber *)[videoDetails objectForKey: @"rockIt"] intValue];
    
    return packItNumber;
}


- (void) setRockIt: (BOOL) number
          forIndex: (int) index
        withOffset: (int) offset
{
    NSMutableDictionary *videoDetails = [self.thumbnailDetailsArray objectAtIndex: [self adjustedIndexForIndex: index withOffset: offset]];
    
    [videoDetails setObject: [NSNumber numberWithInt: number]
                     forKey: @"rockIt"];
    
}

@end
