#import "Genre.h"
#import "NSDictionary+Validation.h"
#import "SubGenre.h"

static NSEntityDescription *categoryEntity = nil;

@interface Genre ()

// Private interface goes here.

@end


@implementation Genre

#pragma mark - Object factory

+ (Genre *)instanceFromDictionary: (NSDictionary *) dictionary usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
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
                categoryEntity = [NSEntityDescription entityForName: @"Genre" inManagedObjectContext: managedObjectContext];
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
    
    Genre *instance;
    
    if (matchingCategoryInstanceEntries.count > 0)
    {
        instance = matchingCategoryInstanceEntries[0];
        
        // Mark this object so that it is not deleted in the post-import step
        instance.markedForDeletionValue = FALSE;
        
        // NSLog(@"Using existing Category instance with id %@", instance.uniqueId);
        
        return instance;
    }
    else
    {
        instance = [Genre insertInManagedObjectContext: managedObjectContext];
        
        
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
    NSNumber* priorityString = (NSNumber*)[dictionary objectForKey:@"priority"];
    self.priority = [NSNumber numberWithInteger:[priorityString integerValue]];
    
    // Parse Subcategories
    
    
    if(![dictionary objectForKey: @"sub_categories"] || ![[dictionary objectForKey: @"sub_categories"] isKindOfClass:[NSArray class]]) {
        AssertOrLog (@"Category %@ did not have subcategories", self.name);
        return;
    }
    
    
    for (NSDictionary* subcategoryData in [dictionary objectForKey: @"sub_categories"])
    {
        SubGenre* subgenre = [SubGenre instanceFromDictionary: subcategoryData usingManagedObjectContext: managedObjectContext];
        [self addSubgenresObject:subgenre];
        
    }
    
    
}

-(NSString*)getSQLForSubGenresSelector
{
    NSMutableString* subquery = [[NSMutableString alloc] init];
    int count = 0;
    for(SubGenre* subgenre in self.subgenres)
        [subquery appendFormat:@"'%@'%@", subgenre.uniqueId, (++count < self.subgenres.count ? @", " : @"")];
     
    return subquery;
}
-(NSArray*)getSubGenreIdArray
{
    NSMutableArray* subGenreIds = [[NSMutableArray alloc] initWithCapacity:self.subgenres.count];
    [subGenreIds addObject:self.uniqueId];
    for(SubGenre* subgenre in self.subgenres)
        [subGenreIds addObject:subgenre.uniqueId];
    return subGenreIds;
    
}
- (NSString *) description
{
    NSMutableString* descriptioString = [[NSMutableString alloc] init];
    [descriptioString appendFormat: @"Category(%i) name: %@, priority:  subcategories:", [self.priority intValue], self.name];
    for (SubGenre* sub in self.subgenres) {
        [descriptioString appendFormat:@"\n- %@", sub];
    }
    return descriptioString;
}

@end
