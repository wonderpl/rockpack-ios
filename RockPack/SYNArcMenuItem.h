//
//  SYNArcMenuItem.h
//  rockpack
//
//  Created by Nick Banks on 12/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//
//  Based on https://github.com/levey/AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.

#import <Foundation/Foundation.h>

@class SYNArcMenuItem;


@interface SYNArcMenuItem : UIImageView

@property (nonatomic) CGPoint endPoint;
@property (nonatomic) CGPoint farPoint;
@property (nonatomic) CGPoint nearPoint;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic, strong) NSString *name;


- (id) initWithImage: (UIImage *) image
       highlightedImage: (UIImage *) highlightedImage
       name: (NSString *) name;


@end

