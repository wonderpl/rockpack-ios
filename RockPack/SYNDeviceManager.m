//
//  SYNDeviceManager.m
//  rockpack
//
//  Created by Michael Michailidis on 09/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNDeviceManager.h"

#define UIDeviceIsRetina ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

@interface SYNDeviceManager()


@end

@implementation SYNDeviceManager


@synthesize idiom;

+ (id) sharedInstance
{
    static dispatch_once_t onceQueue;
    static SYNDeviceManager *deviceManager = nil;
    
    
    dispatch_once(&onceQueue, ^{
        deviceManager = [[self alloc] init];
    });
    
    return deviceManager;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        idiom = UI_USER_INTERFACE_IDIOM();
    }
    return self;
}

-(BOOL)isIPad
{
    return (idiom == UIUserInterfaceIdiomPad);
}
-(BOOL)isIPhone
{
    return (idiom == UIUserInterfaceIdiomPhone);
}
-(BOOL)isLandscape
{
    return UIDeviceOrientationIsLandscape([self orientation]);
}
-(BOOL)isPortrait
{
    return UIDeviceOrientationIsPortrait([self orientation]);
}

-(BOOL)isRetina
{
    return UIDeviceIsRetina;
}


-(UIDeviceOrientation)orientation
{
    UIDeviceOrientation result = [[UIDevice currentDevice] orientation];
    if(result == UIDeviceOrientationUnknown || result >= UIDeviceOrientationFaceUp)
    {
        result = [[UIApplication sharedApplication] statusBarOrientation];
    }
    return result;
}

-(CGRect)currentScreenRect
{
    return [[UIScreen mainScreen] bounds];
}

-(CGSize)currentScreenSize
{
    CGSize currentSize;
    currentSize.width = self.currentScreenWidth;
    currentSize.height = self.currentScreenHeight;
    return currentSize;
}

-(CGFloat)currentScreenWidth
{
    if([self isIPhone])
    {
        return [[UIScreen mainScreen] bounds].size.width;
    }
    if(UIDeviceOrientationIsPortrait([self orientation]))
        return [[UIScreen mainScreen] bounds].size.width;
    else
        return [[UIScreen mainScreen] bounds].size.height;
}

-(CGFloat)currentScreenHeight
{
    if([self isIPhone])
    {
        return [[UIScreen mainScreen] bounds].size.height;
    }
    if(UIDeviceOrientationIsPortrait([self orientation]))
        return [[UIScreen mainScreen] bounds].size.height;
    else
        return [[UIScreen mainScreen] bounds].size.width;
}

-(CGFloat)currentScreenHeightWithStatusBar
{
    return [self currentScreenHeight]  - 20.0;
}

-(UIInterfaceOrientation)currentOrientation
{
    return [[UIApplication sharedApplication] statusBarOrientation];
}

@end
