#import "User.h"
#import "NSDictionary+Validation.h"

@interface User ()

// Private interface goes here.

@end


@implementation User

#pragma mark - Object factory

+ (User*)instanceFromDictionary: (NSDictionary *) dictionary usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    NSError *error = nil;
    
    NSString *uniqueId = [dictionary objectForKey: @"id" withDefault: @"Uninitialized Id"];
    
    NSEntityDescription* categoryEntity = [NSEntityDescription entityForName:@"User" inManagedObjectContext: managedObjectContext];
    
    // Now we need to see if this object already exists, and if so return it and if not create it
    NSFetchRequest *categoryFetchRequest = [[NSFetchRequest alloc] init];
    [categoryFetchRequest setEntity:categoryEntity];
    
    // Search on the unique Id
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", uniqueId];
    [categoryFetchRequest setPredicate: predicate];
    
    NSArray *matchingCategoryInstanceEntries = [managedObjectContext executeFetchRequest: categoryFetchRequest
                                                                                   error: &error];
    
    User *instance;
    
    if (matchingCategoryInstanceEntries.count > 0)
    {
        instance = matchingCategoryInstanceEntries[0];
        
        
        return instance;
    }
    else
    {
        instance = [User insertInManagedObjectContext: managedObjectContext];
        
        
        [instance setAttributesFromDictionary: dictionary
                    usingManagedObjectContext: managedObjectContext];
        
        
        return instance;
    }
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext {
    
    
    
    
    
    
}


- (NSString *) description
{
    NSMutableString* descriptioString = [[NSMutableString alloc] init];
    
    return descriptioString;
}

@end
