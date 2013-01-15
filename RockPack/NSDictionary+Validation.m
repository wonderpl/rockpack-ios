//
//  NSDictionary+Validation.m
//  rockpack
//
//  Created by Nick Banks on 09/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "NSDictionary+Validation.h"

// Store our date formatter as a static for optimization purposes
static NSDateFormatter *dateFormatter = nil;

@implementation NSDictionary (Validation)

- (id) objectForKey: (id) key
        withDefault: (id) defaultValue
{
	id value = [self objectForKey: key];
    
	if (value == nil || [value isEqual: [NSNull null]])
    {
        value = defaultValue;
    }
    
	return value;
}


- (NSDate *) dateFromISO6801StringForKey: (id) key
                             withDefault: (NSDate *) defaultDate
{
	NSString *dateString = [self objectForKey: key];
    NSDate *date;
    
	if (dateString != nil && ![dateString isEqual: [NSNull null]])
    {
        date = [[NSDictionary ISO6801DateFormatter] dateFromString: dateString];
        
        if (date == nil)
        {
            AssertOrLog(@"Unable to parse date");
            date = defaultDate;
        }
    }
    else
    {
        date = defaultDate;
    }
    
	return date;
}


+ (NSDateFormatter *) ISO6801DateFormatter
{
    if (dateFormatter == nil)
    {
        // Do once, and only once
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setTimeZone: [NSTimeZone timeZoneWithName: @"UTC"]];
            [formatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        });
    }
    
    return dateFormatter;
}


@end
