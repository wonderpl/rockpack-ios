//
//  SYNSelectionDB.h
//  rockpack
//
//  Created by Nick Banks on 21/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNSelectionDB : NSObject

+ (id) sharedSelectionDBManager;

@property (nonatomic, strong) NSMutableArray *selections;
@property (nonatomic, strong) NSString *selectionTitle;
@property (nonatomic, strong) UIImage *wallpackImage;

@end
