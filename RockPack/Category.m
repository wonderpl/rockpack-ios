#import "Category.h"
#import "NSDictionary+Validation.h"
#import "Subcategory.h"

static NSEntityDescription *categoryEntity = nil;

@interface Category ()

// Private interface goes here.

@end


@implementation Category

#pragma mark - Object factory

+ (Category *)instanceFromDictionary: (NSDictionary *) dictionary usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    NSError *error = nil;
    
    // Get the unique id of this object from the dictionary that has been passed in
    NSString *uniqueId = [dictionary objectForKey: @"id" withDefault: @"Uninitialized Id"];
    
    // Only create an entity description once, should increase performance
    if (categoryEntity == nil)
    {
        // Do once, and only once
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
                    // Not entirely sure I shouldn't 'copy' this object before assigning it to the static variable
                categoryEntity = [NSEntityDescription entityForName: @"Category" inManagedObjectContext: managedObjectContext];
        });
    }
    
    // Now we need to see if this object already exists, and if so return it and if not create it
    NSFetchRequest *categoryFetchRequest = [[NSFetchRequest alloc] init];
    [categoryFetchRequest setEntity:categoryEntity];
    
    // Search on the unique Id
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", uniqueId];
    [categoryFetchRequest setPredicate: predicate];
    
    NSArray *matchingCategoryInstanceEntries = [managedObjectContext executeFetchRequest: categoryFetchRequest
                                                                                error: &error];
    
    Category *instance;
    
    if (matchingCategoryInstanceEntries.count > 0)
    {
        instance = matchingCategoryInstanceEntries[0];
        
        // Mark this object so that it is not deleted in the post-import step
        instance.markedForDeletionValue = FALSE;
        
        NSLog(@"Using existing Category instance with id %@", instance.uniqueId);
        
        return instance;
    }
    else
    {
        instance = [Category insertInManagedObjectContext: managedObjectContext];
        
        
        [instance setAttributesFromDictionary: dictionary
                                       withId: uniqueId
                    usingManagedObjectContext: managedObjectContext];
        
        
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
    
    // Parse Subcategories
    
    
    if(![dictionary objectForKey: @"sub_categories"] || ![[dictionary objectForKey: @"sub_categories"] isKindOfClass:[NSArray class]]) {
        AssertOrLog (@"Category %@ did not have subcategories", self.name);
        return;
    }
    
    
    for (NSDictionary* subcategoryData in [dictionary objectForKey: @"sub_categories"])
    {
        Subcategory* subcategory = [Subcategory instanceFromDictionary: subcategoryData usingManagedObjectContext: managedObjectContext];
        [self addSubcategoriesObject:subcategory];
        
    }
    
    
}


- (NSString *) description
{
    NSMutableString* descriptioString = [[NSMutableString alloc] init];
    [descriptioString appendFormat: @"Category(%@) name: %@, subcategories:", self.uniqueId, self.name];
    for (Subcategory* sub in self.subcategories) {
        [descriptioString appendFormat:@"\n- %@", sub];
    }
    return descriptioString;
}

@end
