//
//  SYNSoundPlayer.h
//  rockpack
//
//  Created by Michael Michailidis on 26/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSoundNewSlideIn @"NewSlideIn"
#define kSoundNewSlideOut @"NewSlideOut"
#define kSoundScroll @"Scroll"
#define kSoundSelect @"Select"

@interface SYNSoundPlayer : NSObject

@property (nonatomic) BOOL soundEnabled;
+ (id)sharedInstance;
-(void)playSoundByName:(NSString*)soundName;

@end
