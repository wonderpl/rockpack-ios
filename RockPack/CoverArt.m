#import "CoverArt.h"
#import "NSDictionary+Validation.h"

static NSEntityDescription *coverArtEntity = nil;

@implementation CoverArt

- (int) ordering
{
    return (self.userUploadValue == 1) ? 0 : 1;
}


+ (CoverArt *) instanceFromDictionary: (NSDictionary *) dictionary
            usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                        forUserUpload: (BOOL) userUpload
{
    NSError *error = nil;
    
    // Get the unique id of this object from the dictionary that has been passed in
    NSString *uniqueId = [dictionary objectForKey: @"id"
                                      withDefault: @"Uninitialized Id"];
    
    // Only create an entity description once, should increase performance
    if (coverArtEntity == nil)
    {
        // Do once, and only once
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            coverArtEntity = [NSEntityDescription entityForName: @"CoverArt"
                                         inManagedObjectContext: managedObjectContext];
        });
    }
    
    // Now we need to see if this object already exists, and if so return it and if not create it
    NSFetchRequest *coverArtFetchRequest = [[NSFetchRequest alloc] init];
    coverArtFetchRequest.entity = coverArtEntity;
    coverArtFetchRequest.fetchBatchSize = 20;
    
    // Search on the unique Id
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", uniqueId];
    coverArtFetchRequest.predicate = predicate;
    
    NSArray *matchingChannelCoverInstanceEntries = [managedObjectContext executeFetchRequest: coverArtFetchRequest
                                                                                       error: &error];
    CoverArt *instance;
    
    if (matchingChannelCoverInstanceEntries.count > 0)
    {
        instance = matchingChannelCoverInstanceEntries [0];
        
        instance.markedForDeletionValue = NO;
        
        return instance;
    }
    else
    {
        instance = [CoverArt insertInManagedObjectContext: managedObjectContext];
        
        [instance setAttributesFromDictionary: dictionary
                                       withId: uniqueId
                    usingManagedObjectContext: managedObjectContext];
        
        instance.userUploadValue = userUpload;
        
        
        return instance;
    }
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog(@"setAttributesFromDictionary: not a dictionary, unable to construct object");
        return;
    }
    
    self.uniqueId = uniqueId;
    
    self.thumbnailURL = [dictionary objectForKey: @"thumbnail_url"
                                     withDefault: @"http://localhost"];
    
    self.coverRef = [dictionary objectForKey: @"cover_ref"
                                 withDefault: @"Uninitialized coverRef"];
    
    self.position = [dictionary objectForKey: @"position"
                                 withDefault: @0];
}

@end
