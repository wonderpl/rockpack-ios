#import "CoverArt.h"
#import "NSDictionary+Validation.h"

static NSEntityDescription *coverArtEntity = nil;

@interface CoverArt ()

// Private interface goes here.

@end


@implementation CoverArt

+ (CoverArt *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                                andViewId: (NSString *) viewId
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
    
    // Search on the unique Id
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@ AND viewId == %@", uniqueId, viewId];
    coverArtFetchRequest.predicate = predicate;
    
    NSArray *matchingChannelCoverInstanceEntries = [managedObjectContext executeFetchRequest: coverArtFetchRequest
                                                                                       error: &error];
    CoverArt *instance;
    
    if (matchingChannelCoverInstanceEntries.count > 0)
    {
        instance = matchingChannelCoverInstanceEntries [0];
        
        // Mark this object so that it is not deleted in the post-import step
        instance.markedForDeletionValue = FALSE;
        NSLog (@"CoverArt reused");
        return instance;
    }
    else
    {
        instance = [CoverArt insertInManagedObjectContext: managedObjectContext];

        [instance setAttributesFromDictionary: dictionary
                                       withId: uniqueId
                    usingManagedObjectContext: managedObjectContext
                                    andViewId: viewId];
        NSLog (@"CoverArt created");
        return instance;
    }
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                           andViewId: (NSString *) viewId
{
    // Is we are not actually a dictionary, then bail
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog (@"setAttributesFromDictionary: not a dictionary, unable to construct object");
        return;
    }
    
    // Simple objects
    self.uniqueId = uniqueId;
    self.viewId = viewId;
    self.backgroundURL = [dictionary objectForKey: @"background_url"
                                      withDefault: @"http://localhost"];
    
	self.carouselURL = [dictionary objectForKey: @"carousel_url"
                                    withDefault: @"http://localhost"];
    
	self.coverRef = [dictionary objectForKey: @"cover_ref"
                                 withDefault: @"Uninitialized coverRef"];
    
    self.position = [dictionary objectForKey: @"position"
                                 withDefault: [NSNumber numberWithInt: 0]];
}


- (NSString *) description
{
    return [NSString stringWithFormat: @"ChannelCover: uniqueId(%@), viewId (%@), backgroundURL(%@), carouselURL (%@), coverRef(%@),  position(%@)", self.uniqueId, self.viewId, self.backgroundURL, self.carouselURL, self.coverRef, self.position];
}


@end
