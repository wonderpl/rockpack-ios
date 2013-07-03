//
//  SYNDebug.m
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNDebug.h"

void SYNDebug (const char *fileName, int lineNumber, NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    
    static NSDateFormatter *debugFormatter = nil;
    if (debugFormatter == nil)
    {
        debugFormatter = [[NSDateFormatter alloc] init];
        [debugFormatter setDateFormat:@"HH:mm:ss.SSS"];
    }
    
    NSString *logmsg = [[NSString alloc] initWithFormat: format
                                              arguments: args];
    
    NSString *filePath = [[NSString alloc] initWithUTF8String: fileName];
    NSString *timestamp = [debugFormatter stringFromDate: [NSDate date]];
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    fprintf(stdout, "%s %s -%s[%s:%d]\n",
            [timestamp UTF8String],
            [logmsg UTF8String],
            [infoDict[(NSString *)kCFBundleNameKey] UTF8String],
            [[filePath lastPathComponent] UTF8String],
            lineNumber
            );
}
