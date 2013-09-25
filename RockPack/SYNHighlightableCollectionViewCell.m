//
//  SYNHighlightableCollectionViewCell.m
//  rockpack
//
//  Created by Nick Banks on 25/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNHighlightableCollectionViewCell.h"
#import "UIImage+Tint.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNHighlightableCollectionViewCell ()

@property (nonatomic, strong) IBOutlet UIImageView *lowlightImageView;

@end


@implementation SYNHighlightableCollectionViewCell

#pragma mark - Cell lifcycle

- (void) prepareForReuse
{
    [super prepareForReuse];

    self.lowlightImageView.image = [self lowlightImage: FALSE];
}


- (void) setLowlight: (BOOL) lowlight
            forPoint: (CGPoint) pointInCell
{
    self.lowlightImageView.image = [self lowlightImage: lowlight];
}


- (NSString *) glossImageName
{
    AssertOrLog(@"Gloss image name not defined in subclass");
    return nil;
}


- (UIImage *) lowlightImage: (BOOL) lowlight
{
    NSString *imageName = [self glossImageName];
    
    UIImage *glossImage = [UIImage imageNamed: imageName];
    
    if (lowlight)
    {
        UIImage *lowlightImage = [glossImage tintedImageUsingColor: [UIColor colorWithWhite: 0.0
                                                                                      alpha: 0.3]];
        return lowlightImage;
    }
    else
    {
        return glossImage;
    }
}
@end
