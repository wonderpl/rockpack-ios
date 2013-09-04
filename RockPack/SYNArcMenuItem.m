//
//  SYNArcMenuItem.m
//  rockpack
//
//  Created by Nick Banks on 12/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//
//  Based on https://github.com/levey/AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.

#import "SYNArcMenuItem.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+SYNFont.h"

static inline CGRect ScaleRect(CGRect rect, float n)
{
    return CGRectMake((rect.size.width - rect.size.width * n) / 2,
                      (rect.size.height - rect.size.height * n) / 2,
                      rect.size.width * n,
                      rect.size.height * n);
}


@implementation SYNArcMenuItem

#pragma mark - initialization & cleaning up
- (id) initWithImage: (UIImage *) image
    highlightedImage: (UIImage *) highlightedImage
                name: (NSString *) name
           labelText: (NSString *) labelText
{
    if ((self = [super init]))
    {
        self.name = name;

        self.labelText = labelText;

        self.userInteractionEnabled = YES;
        self.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
        
        // Set up UIImageView subview
        self.imageView = [[UIImageView alloc] initWithFrame: self.bounds];
        self.imageView.image = image;
        self.imageView.highlightedImage = highlightedImage;
        [self addSubview: self.imageView];
        
        if (labelText)
        {
            // Setup UILabel subview
            self.label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 200, 36)];
            self.label.textColor = [UIColor whiteColor];
            
            self.label.backgroundColor = [UIColor colorWithWhite: 0.0f
                                                           alpha: 0.8f];
            
            self.label.font = [UIFont boldRockpackFontOfSize: 28.0f];
            self.label.text = labelText;
            self.label.textAlignment = NSTextAlignmentCenter;
            self.label.numberOfLines = 0;
            self.label.layer.cornerRadius = 22;
            [self.label sizeToFit];
            
            self.label.frame = CGRectInset(self.label.frame, -10, -8);
            
            CGPoint c = self.label.center;
            c.x = self.imageView.center.x;
            c.y = -40;

            self.label.center = c;
            self.label.alpha = 0.0; ;
            [self addSubview: self.label];
        }
    }
    
    return self;
}


@end