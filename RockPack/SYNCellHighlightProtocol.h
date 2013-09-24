//
//  SYNCellHighlightProtocol.h
//  rockpack
//
//  Created by Nick Banks on 24/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SYNCellHighlightProtocol <NSObject>

- (void) setLowlight: (BOOL) lowlight
            forPoint: (CGPoint) pointInCell;
@end
