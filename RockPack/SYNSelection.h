//
//  SYNSelection.h
//  rockpack
//
//  Created by Nick Banks on 21/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNSelection : NSObject

@property (nonatomic, assign, readonly) int index;
@property (nonatomic, assign, readonly) int offset;

- (id) initWithIndex: (int) index
           andOffset: (int) offset;

@end
