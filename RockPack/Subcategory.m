#import "Subcategory.h"
#import "Category.h"
#import "NSDictionary+Validation.h"

static NSEntityDescription *subcategoryEntity = nil;

@interface Subcategory ()


@end


@implementation Subcategory

+ (Subcategory *)instanceFromDictionary: (NSDictionary *) dictionary usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    NSError *error = nil;
    
    // Get the unique id of this object from the dictionary that has been passed in
    NSString *uniqueId = [dictionary objectForKey: @"id" withDefault: @"Uninitialized Id"];
    
    // Only create an entity description once, should increase performance
    if (subcategoryEntity == nil)
    {
        // Do once, and only once
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            // Not entirely sure I shouldn't 'copy' this object before assigning it to the static variable
            subcategoryEntity = [NSEntityDescription entityForName: @"Subcategory" inManagedObjectContext: managedObjectContext];
        });
    }
    
    // Now we need to see if this object already exists, and if so return it and if not create it
    NSFetchRequest *subcategoryFetchRequest = [[NSFetchRequest alloc] init];
    [subcategoryFetchRequest setEntity:subcategoryEntity];
    
    // Search on the unique Id
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", uniqueId];
    [subcategoryFetchRequest setPredicate: predicate];
    
    NSArray *matchingVideoInstanceEntries = [managedObjectContext executeFetchRequest: subcategoryFetchRequest
                                                                                error: &error];
    
    Subcategory *instance;
    
    if (matchingVideoInstanceEntries.count > 0)
    {
        instance = matchingVideoInstanceEntries[0];
        
        // NSLog(@"Using existing VideoInstance instance with id %@", instance.uniqueId);
        
        return instance;
    }
    else
    {
        instance = [Subcategory insertInManagedObjectContext: managedObjectContext];
        
        
        [instance setAttributesFromDictionary: dictionary
                                       withId: uniqueId
                    usingManagedObjectContext: managedObjectContext];
        
        // NSLog(@"Created VideoInstance instance with id %@", instance.uniqueId);
        
        return instance;
    }
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    // Is we are not actually a dictionary, then bail
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog (@"setAttributesFromDictionary: not a dictionary, unable to construct object");
        return;
    }
    
    // Simple objects
    self.uniqueId = uniqueId;
    
    
    self.name = [dictionary upperCaseStringForKey: @"name" withDefault: @"-?-"];
    
    
    NSNumber* priorityString = (NSNumber*)[dictionary objectForKey:@"priority"];
    self.priority = [NSNumber numberWithInteger:[priorityString integerValue]];
    
    
}

- (NSString *) description
{
    return [NSString stringWithFormat: @"Category(%@) name: %@", self.uniqueId, self.name];
}

@end
