#import "_User.h"

@interface User : _User

@property (nonatomic, readonly) NSString *fullName;

+ (User *) instanceFromDictionary: (NSDictionary *) dictionary
        usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
              ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+ (User *)	 instanceFromUser: (User *) oldUser
   usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

@property (nonatomic, strong) NSString* facebookToken;

@end
