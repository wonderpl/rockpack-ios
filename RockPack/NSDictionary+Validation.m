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
    
    // Crafty, check to see that we are a valid object AND that the object is of the same type as the default value
    // this is a bit of an assumption, but I think that it makes sense
	if (value == nil || [value isEqual: [NSNull null]] || ![defaultValue isKindOfClass: [value class]])
    {
        value = defaultValue;
    }
    
	return value;
}


// 
- (NSString *) upperCaseStringForKey: (id) key
                         withDefault: (id) defaultValue
{
    NSString *string = [self objectForKey: key
                              withDefault: defaultValue];
    
    // Crafty, check to see that we are a valid object AND that the object is of the same type as the default value
    // this is a bit of an assumption, but I think that it makes sense
	if (string != nil)
    {
        string = [string uppercaseStringWithLocale: [NSLocale currentLocale]];
    }
    
	return string;
}


- (NSDate *) dateFromISO6801StringForKey: (id) key
                             withDefault: (NSDate *) defaultDate
{
	NSString *dateString = [self objectForKey: key];
    NSDate *date;
    
    // Check to see that we have a valid string object from which 
	if (dateString != nil && ![dateString isEqual: [NSNull null]] && [dateString isKindOfClass: [NSString class]])
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

// Used for dates in the following format "2012-12-14T09:59:46.000Z"
+ (NSDateFormatter *) ISO6801DateFormatter
{
    if (dateFormatter == nil)
    {
        // Do once, and only once
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^
        {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone: [NSTimeZone timeZoneWithName: @"UTC"]];
            [dateFormatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        });
    }
    
    return dateFormatter;
}


@end
