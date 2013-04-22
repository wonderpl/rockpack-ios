//
//  SYNDeviceManager.m
//  rockpack
//
//  Created by Michael Michailidis on 09/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
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
    static UIUserInterfaceIdiom idiom;
    
    
    dispatch_once(&onceQueue, ^{
        deviceManager = [[self alloc] init];
        idiom = UI_USER_INTERFACE_IDIOM();
        
    });
    
    return deviceManager;
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

-(CGFloat)currentScreenWidth
{
    if(UIDeviceOrientationIsPortrait([self orientation]))
        return [[UIScreen mainScreen] bounds].size.width;
    else
        return [[UIScreen mainScreen] bounds].size.height;
}

-(CGFloat)currentScreenHeight
{
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
