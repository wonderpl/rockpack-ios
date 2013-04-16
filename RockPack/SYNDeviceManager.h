//
//  SYNDeviceManager.h
//  rockpack
//
//  Created by Michael Michailidis on 09/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNDeviceManager : NSObject

@property (nonatomic, readonly) UIUserInterfaceIdiom idiom;

+(id)sharedInstance;


-(BOOL)isIPad;
-(BOOL)isIPhone;

-(BOOL)isLandscape;
-(BOOL)isPortrait;

-(UIDeviceOrientation)orientation;

-(CGFloat)currentScreenWidth;
-(CGFloat)currentScreenHeight;

@end
