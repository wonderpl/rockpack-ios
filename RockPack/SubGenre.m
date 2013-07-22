#import "Genre.h"
#import "NSDictionary+Validation.h"
#import "SubGenre.h"

static NSEntityDescription *subcategoryEntity = nil;

@implementation SubGenre

+ (SubGenre *) instanceFromDictionary: (NSDictionary *) dictionary
            usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    NSError *error = nil;
    
    // Get the unique id of this object from the dictionary that has been passed in
    NSString *uniqueId = [dictionary objectForKey: @"id"
                                      withDefault: @"Uninitialized Id"];
    
    // Only create an entity description once, should increase performance
    if (subcategoryEntity == nil)
    {
        // Do once, and only once
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            // Not entirely sure I shouldn't 'copy' this object before assigning it to the static variable
            subcategoryEntity = [NSEntityDescription entityForName: @"SubGenre"
                                            inManagedObjectContext: managedObjectContext];
        });
    }
    
    // Now we need to see if this object already exists, and if so return it and if not create it
    NSFetchRequest *subcategoryFetchRequest = [[NSFetchRequest alloc] init];
    [subcategoryFetchRequest setEntity: subcategoryEntity];
    
    // Search on the unique Id
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", uniqueId];
    [subcategoryFetchRequest setPredicate: predicate];
    
    NSArray *matchingSubGenreEntries = [managedObjectContext executeFetchRequest: subcategoryFetchRequest
                                                                           error: &error];
    
    SubGenre *instance;
    
    if (matchingSubGenreEntries.count > 0)
    {
        instance = matchingSubGenreEntries[0];
    }
    else
    {
        instance = [SubGenre insertInManagedObjectContext: managedObjectContext];;
    }
    
    [instance setAttributesFromDictionary: dictionary
                                   withId: uniqueId
                usingManagedObjectContext: managedObjectContext];
    
    return instance;
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    // Is we are not actually a dictionary, then bail
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog(@"setAttributesFromDictionary: not a dictionary, unable to construct object");
        return;
    }
    
    // Simple objects
    self.uniqueId = uniqueId;
    
    self.name = [dictionary upperCaseStringForKey: @"name"
                                      withDefault: @"-?-"];
    
    NSNumber *priorityString = (NSNumber *) dictionary[@"priority"];
    self.priority = @([priorityString integerValue]);
    
    NSNumber *isDefault = dictionary[@"default"];
    self.isDefaultValue = [isDefault boolValue];
}


@end
