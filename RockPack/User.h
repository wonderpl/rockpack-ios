#import "_User.h"

@interface User : _User

@property (nonatomic, readonly) NSString *fullName;

+ (User *) instanceFromDictionary: (NSDictionary *) dictionary
        usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
              ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+ (User *)	 instanceFromUser: (User *) oldUser
   usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

@property (nonatomic, readonly) ExternalAccount* facebookAccount;
@property (nonatomic, readonly) ExternalAccount* twitterAccount;
@property (nonatomic, readonly) ExternalAccount* googlePlusAccount;

-(ExternalAccount*)externalAccountForSystem:(NSString*)systemName;
-(void)addExternalAccountsFromDictionary:(NSDictionary*)dictionary;
-(void)setFlagsFromDictionary:(NSDictionary*)dictionary;

@end
