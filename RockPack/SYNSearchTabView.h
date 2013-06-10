//
//  SYNSearchTabView.h
//  rockpack
//
//  Created by Michael Michailidis on 19/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {

    SearchTabTypeVideos = 0,
    SearchTabTypeChannels

} SearchTabType;

@interface SYNSearchTabView : UIControl {
    UIImage* backgroundImageOn;
    UIImage* backgroundImageOff;
    UIImageView* bgImageView;
    UILabel* titleLabel;
    NSString* typeTitle;
    SearchTabType type;
    UIColor* onColor;
    UIColor* offColor;
    UIButton* overButton;
    BOOL selected;
}



-(void)setNumberOfItems:(NSInteger)numberOfItems animated:(BOOL)animated;

+(id)tabViewWithSearchType:(SearchTabType)itsType;

@end
