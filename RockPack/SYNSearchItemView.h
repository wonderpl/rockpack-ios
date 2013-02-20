//
//  SYNSearchItemView.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNSearchItemView : UIView

- (id)initWithTitle:(NSString*)name andFrame:(CGRect)frame;

-(void)setNumberOfItems:(NSInteger)noi;

@end
