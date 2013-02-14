//
//  SYNRegistry.h
//  rockpack
//
//  Created by Michael Michailidis on 14/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNRegistry : NSObject


-(id)initWithManagedObjectContext:(NSManagedObjectContext*)moc;

-(void)registerCategoriesFromDictionary:(NSDictionary*)dictionary;

@end
