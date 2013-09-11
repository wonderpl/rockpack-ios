//
//  SYNReportConcernTableCell.h
//  rockpack
//
//  Created by Nick Banks on 14/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNReportConcernTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
