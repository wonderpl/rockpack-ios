#import "_Friend.h"

@interface Friend : _Friend {}


+ (Friend *) instanceFromDictionary: (NSDictionary *) dictionary
          usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

+ (Friend *) friendFromFriend:(Friend *)friendToCopy
      forManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;



@property (nonatomic, readonly) BOOL isOnRockpack;

@property (nonatomic, readonly) NSString* firstName;
@property (nonatomic, readonly) NSString* lastName;

@property (nonatomic, readonly) BOOL isFromFacebook;
@property (nonatomic, readonly) BOOL isFromTwitter;
@property (nonatomic, readonly) BOOL isFromGooglePlus;
@property (nonatomic, readonly) BOOL isFromAddressBook;



@end
