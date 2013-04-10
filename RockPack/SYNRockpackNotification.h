//
//  SYNRockpackNotification.h
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface SYNRockpackNotification : NSObject

@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) User* user;
@property (nonatomic) NSInteger timeElapsesd;

@end
