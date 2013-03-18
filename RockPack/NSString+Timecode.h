//
//  NSString+Timecode.h
//  rockpack
//
//  Created by Nick Banks on 14/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Timecode)

+ (NSString *) timecodeStringFromSeconds: (float) timeSeconds;

@end
