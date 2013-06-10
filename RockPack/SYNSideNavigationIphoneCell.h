//
//  SYNSideNavigationIphoneCell.h
//  rockpack
//
//  Created by Mats Trovik on 29/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNSideNavigationIphoneCell : UITableViewCell

@property (nonatomic, strong) UILabel* accessoryNumberLabel;
@property (nonatomic, strong) UIImageView* accessoryNumberBackground;

-(void)setAccessoryNumber:(NSString*)accessoryNumberString;
@end
