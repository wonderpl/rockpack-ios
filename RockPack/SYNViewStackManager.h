//
//  SYNViewStackManager.h
//  rockpack
//
//  Created by Michael Michailidis on 04/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYNAbstractViewController;

@interface SYNViewStackManager : NSObject


@property (nonatomic, weak) UINavigationController* navigationController;

+(id)manager;


-(void)popToRootController;
-(void)popToController:(UIViewController*)controller;
-(void)popController;
-(void)pushController:(SYNAbstractViewController*)controller;

@end
