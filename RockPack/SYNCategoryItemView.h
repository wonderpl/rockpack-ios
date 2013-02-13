//
//  SYNCategoryItemView.h
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"

@interface SYNCategoryItemView : UIView

@property (nonatomic, strong) NSString* dataItemId;

- (id)initWithName:(NSString *)name Id:(NSString*)cid andFrame:(CGRect)frame;

@end
