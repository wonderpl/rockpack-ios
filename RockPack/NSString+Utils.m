//
//  NSString+Utils.m
//  rockpack
//
//  Created by Nick Banks on 15/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (NSString *) stringByReplacingOccurrencesOfStrings: (NSDictionary *) dictionary
{
    NSString *newString = [self copy];
    
    for (NSString *key in dictionary.allKeys)
    {
        newString = [newString stringByReplacingOccurrencesOfString: key
                                                         withString: [dictionary objectForKey: key]];
    }
    
    return newString;
}

@end
