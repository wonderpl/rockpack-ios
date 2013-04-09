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
-(UIDeviceOrientation)orientation;

@end
