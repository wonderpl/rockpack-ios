//
//  SYNSearchItemView.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SYNSearchItemView : UIView

@property (nonatomic, strong) UILabel* numberLabel;
@property (nonatomic, strong) UILabel* nameLabel;

- (id)initWithTitle:(NSString*)name andFrame:(CGRect)frame;


-(void)setNumberOfItems:(NSInteger)noi animated:(BOOL)animated;

-(void)makeFaded;
-(void)makeStandard;
-(void)makeHighlightedWithImage:(BOOL)withImage;

-(void)hideItem;
-(void)showItem;

@end
