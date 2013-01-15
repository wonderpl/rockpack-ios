//
//  NSDictionary+Validation.h
//  rockpack
//
//  Created by Nick Banks on 09/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Validation)

- (id) objectForKey: (id) key
        withDefault: (id) defaultValue;

- (NSDate *) dateFromISO6801StringForKey: (id) key
                             withDefault: (NSDate *) defaultDate;

@end
