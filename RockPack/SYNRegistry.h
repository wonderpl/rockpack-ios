//
//  SYNRegistry.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNAppDelegate.h"

@interface SYNRegistry : NSObject {
    @protected SYNAppDelegate *appDelegate;
    @protected NSManagedObjectContext* importManagedObjectContext;
}


-(id)initWithManagedObjectContext:(NSManagedObjectContext*)moc;

@end
