//
//  SYNIntegralCollectionFlowLayout.h
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNIntegralCollectionViewFlowLayout : UICollectionViewFlowLayout

+(SYNIntegralCollectionViewFlowLayout*)layoutWithItemSize:(CGSize)itemSize minimumInterItemSpacing:(CGFloat)minSpace minimumLineSpacing:(CGFloat)lineSpace scrollDirection:(UICollectionViewScrollDirection)scrollDirection sectionInset:(UIEdgeInsets)insets;


@end
