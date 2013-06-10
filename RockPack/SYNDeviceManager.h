//
//  SYNDeviceManager.h
//  rockpack
//
//  Created by Michael Michailidis on 09/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNDeviceManager : NSObject

@property (nonatomic, readonly) UIUserInterfaceIdiom idiom;

+(id)sharedInstance;


-(BOOL)isIPad;
-(BOOL)isIPhone;

-(BOOL)isLandscape;
-(BOOL)isPortrait;

-(BOOL)isRetina;

-(UIDeviceOrientation)orientation;

-(CGFloat)currentScreenWidth;
-(CGFloat)currentScreenHeight;
-(CGFloat)currentScreenHeightWithStatusBar;
-(CGRect)currentScreenRect;
-(CGSize)currentScreenSize;

-(UIInterfaceOrientation)currentOrientation;

@end
