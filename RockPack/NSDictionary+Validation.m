//
//  NSDictionary+Validation.m
//  rockpack
//
//  Created by Nick Banks on 09/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "NSDictionary+Validation.h"

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

@end
