//
//  SYNRegistry.h
//  rockpack
//
//  Created by Michael Michailidis on 14/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNRegistry.h"

@interface SYNMainRegistry : SYNRegistry {

}



-(BOOL)registerCategoriesFromDictionary:(NSDictionary*)dictionary;
-(BOOL)registerVideoInstancesFromDictionary:(NSDictionary *)dictionary forViewId:(NSString*)viewId;
-(BOOL)registerChannelFromDictionary:(NSDictionary*)dictionary;
-(BOOL)registerChannelScreensFromDictionary:(NSDictionary *)dictionary;
-(BOOL)registerAccessInfoFromDictionary:(NSDictionary *)dictionary;

@end
