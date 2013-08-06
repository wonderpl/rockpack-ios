//
//  SYNImplicitSharingController.m
//  rockpack
//
//  Created by Michael Michailidis on 06/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNImplicitSharingController.h"
#import "UIFont+SYNFont.h"

@interface SYNImplicitSharingController ()

@end

@implementation SYNImplicitSharingController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.font = [UIFont rockpackFontOfSize:self.titleLabel.font.pointSize];
    
    self.textLabel.font = [UIFont rockpackFontOfSize:self.textLabel.font.pointSize];
    
    
}



@end
