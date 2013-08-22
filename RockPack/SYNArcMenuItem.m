//
//  SYNArcMenuItem.m
//  rockpack
//
//  Created by Nick Banks on 12/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//
//  Based on https://github.com/levey/AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.

#import "SYNArcMenuItem.h"

static inline CGRect ScaleRect(CGRect rect, float n)
{
    return CGRectMake((rect.size.width - rect.size.width * n) / 2,
                      (rect.size.height - rect.size.height * n) / 2,
                      rect.size.width * n,
                      rect.size.height * n);
}

@implementation SYNArcMenuItem

#pragma mark - initialization & cleaning up
- (id) initWithImage: (UIImage *) image
       highlightedImage: (UIImage *) highlightedImage
                name: (NSString *) name
{
    if ((self = [super init]))
    {
        self.name = name;
        self.image = image;
        self.highlightedImage = highlightedImage;
        self.userInteractionEnabled = YES;
        self.bounds = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    }
    
    return self;
}


@end