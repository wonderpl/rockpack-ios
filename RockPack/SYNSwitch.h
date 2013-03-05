//
//  SYNSwitch.h
//  synswitch
//
//  Created by Nick Banks on 19/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kOffXOffset 0.0f
#define kOnXOffset 50.0f
#define kOnXThreshold 25.0f

@interface SYNSwitch : UIControl {
    UIFont* rockpackFont;
    UILabel* leftLabel;
    UILabel* rightLabel;
}

- (id) initWithLeftText:(NSString*)lText andRightText:(NSString*)rText;


@property (nonatomic, assign, getter=isOn) BOOL on;				// default: NO

@property (nonatomic, weak) NSString* textLeft;
@property (nonatomic, weak) NSString* textRight;

@end
