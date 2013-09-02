//
//  SYNOneToOneSharingController.m
//  rockpack
//
//  Created by Michael Michailidis on 28/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOneToOneSharingController.h"
#import "UIFont+SYNFont.h"
#import "Friend.h"
#import <AddressBook/AddressBook.h>
#import "SYNAppDelegate.h"
#import "SYNFriendThumbnailCell.h"
#import "UIImageView+WebCache.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNFacebookManager.h"
#import <objc/runtime.h>

#define kOneToOneSharingViewId @"kOneToOneSharingViewId"

static char* friend_share_key = "SYNFriendThumbnailCell to Friend Share";

@interface SYNOneToOneSharingController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextView* messageTextView;
@property (nonatomic, strong) IBOutlet UITextField* searchTextField;
@property (nonatomic, strong) IBOutlet UICollectionView* friendsCollectionView;

@property (nonatomic, strong) IBOutlet UIButton* facebookButton;
@property (nonatomic, strong) IBOutlet UIButton* twitterButton;
@property (nonatomic, strong) IBOutlet UIButton* emailButton;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* loader;


// second View

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UIButton* authorizeFacebookButton;
@property (nonatomic, strong) IBOutlet UIButton* authorizeAddressBookButton;

@property (nonatomic, strong) NSArray* friends;
@property (nonatomic, strong) NSArray* friendsToDisplay;

@property (nonatomic, strong) IBOutlet UIView* authorizationView;

@property (nonatomic, strong) NSMutableString* currentSearchTerm;

@end

@implementation SYNOneToOneSharingController

@synthesize friends;
@synthesize friendsToDisplay;
@synthesize currentSearchTerm;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.loader hidesWhenStopped];
    
    friends = [NSArray array];
    friendsToDisplay = [NSArray array];
    
    currentSearchTerm = [[NSMutableString alloc] init];
    
    self.messageTextView.font = [UIFont rockpackFontOfSize:self.messageTextView.font.pointSize];
    
    self.searchTextField.font = [UIFont rockpackFontOfSize:self.searchTextField.font.pointSize];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize:self.titleLabel.font.pointSize];
    
    
    
//    switch (aBookAuthStatus)
//    {
//        case kABAuthorizationStatusAuthorized:
//            NSLog(@"Address Book Authorized");
//            [self getDataFromAddressBook];
//            break;
//            
//        case kABAuthorizationStatusDenied:
//            NSLog(@"Address Book Denied");
//            break;
//            
//        case kABAuthorizationStatusNotDetermined:
//            NSLog(@"Address Book Not Determined");
//            break;
//            
//        case kABAuthorizationStatusRestricted:
//            NSLog(@"Address Book Restricted");
//            break;
//    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    // Basic recognition
    
    self.loader.hidden = YES;
    
    BOOL aBookAuthAuthorized = ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized;
    BOOL hasFacebookSession = [[SYNFacebookManager sharedFBManager] hasActiveSession];
    if(!aBookAuthAuthorized  && !hasFacebookSession)
    {
        // put log in screen
        CGRect aViewRect = self.authorizationView.frame;
        aViewRect.origin.y = 50.0f;
        self.authorizationView.frame = aViewRect;
        [self.view addSubview:self.authorizationView];
        return;
    }
    
    if(hasFacebookSession)
    {
        [self fetchFacebookFriends];
    }
    
    if(aBookAuthAuthorized)
    {
        NSArray* addressBookFriends = [self fetchAddressBookFriends];
    }
}


-(void)requestAddressBookAuthorization
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    
    if(addressBookRef == NULL)
        return;
    
    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
        
        if (granted){
            NSLog(@"Access was granted");
            [self fetchAddressBookFriends];
        } else {
            
            NSLog(@"Access was not granted");
            
        }
        
        CFRelease(addressBookRef);
    });
}

#pragma mark - Data Retrieval

-(void)fetchFacebookFriends
{
    
    
    
    __weak SYNOneToOneSharingController* weakSelf = self;
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.oAuthNetworkEngine friendsForUser:appDelegate.currentUser completionHandler:^(id dictionary) {
        
 
        
        NSDictionary* usersDictionary = dictionary[@"users"];
        if(!usersDictionary)
            return;
        
        NSArray* itemsDictionary = usersDictionary[@"items"];
        if(!itemsDictionary)
            return;
        
        NSInteger friendsCount = itemsDictionary.count;
        
        NSMutableArray* iOSFriendsMutableArray = [NSMutableArray arrayWithCapacity:friendsCount];
        
        for (NSDictionary* itemDictionary in itemsDictionary)
        {
            Friend* friend = [Friend instanceFromDictionary:itemDictionary
                                  usingManagedObjectContext:appDelegate.searchManagedObjectContext];
            
            if(!friend || !friend.hasIOSDevice) // filter for users with iOS devices only
                return;
            
            [iOSFriendsMutableArray addObject:friend];
            
            
            
            
        }
        
        
        weakSelf.friends = [NSArray arrayWithArray:iOSFriendsMutableArray];
        
        
        
    } errorHandler:^(id dictionary) {
        
    }];
}

-(NSArray*)fetchAddressBookFriends
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    
    if(addressBookRef == NULL)
        return [NSArray array];
    
    NSArray *arrayOfAllPeople = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSInteger total = [arrayOfAllPeople count];
    NSString *firstName, *lastName, *emailAddress;
    Friend* contactFriend;
    NSMutableArray* friendsArrayMut = [NSMutableArray arrayWithCapacity:total];
    for (NSUInteger peopleCounter = 0; peopleCounter < total; peopleCounter++)
    {
        
        ABRecordRef currentPerson = (__bridge ABRecordRef)[arrayOfAllPeople objectAtIndex:peopleCounter];
        ABRecordID cid;
        if(!currentPerson || ((cid = ABRecordGetRecordID(currentPerson)) == kABRecordInvalidID))
            continue;
         
        
        firstName = (__bridge_transfer NSString *)ABRecordCopyValue(currentPerson, kABPersonFirstNameProperty);
        lastName = (__bridge_transfer NSString *)ABRecordCopyValue(currentPerson, kABPersonLastNameProperty);
        emailAddress = (__bridge_transfer NSString *)ABRecordCopyValue(currentPerson, kABPersonEmailProperty);
        
        
        NSLog(@"Contact <%i> found: %@, %@, %@", cid, firstName, lastName, emailAddress);
        
        contactFriend = [Friend insertInManagedObjectContext: appDelegate.searchManagedObjectContext];
        contactFriend.viewId = kOneToOneSharingViewId;
        
        contactFriend.displayName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        contactFriend.email = emailAddress;
        contactFriend.externalSystem = @"email";
        contactFriend.externalUID = [NSString stringWithFormat:@"%i", cid];
        
        [friendsArrayMut addObject:contactFriend];
    }
    
    
    
    CFRelease(addressBookRef);
    
    return [NSArray arrayWithArray:friendsArrayMut];
}

#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    return friendsToDisplay.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    Friend *friend = self.friendsToDisplay[indexPath.row];
    
    SYNFriendThumbnailCell *userThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNFriendThumbnailCell"
                                                                                          forIndexPath: indexPath];
    
    userThumbnailCell.nameLabel.text = friend.displayName;
    
    
    [userThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: friend.thumbnailLargeUrl]
                                placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
                                         options: SDWebImageRetryFailed];
    
    [userThumbnailCell setDisplayName: friend.displayName];
    
    
    
    objc_setAssociatedObject(userThumbnailCell, friend_share_key, friend, OBJC_ASSOCIATION_ASSIGN);
    
    return userThumbnailCell;
    
}
- (void)collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
   
}


#pragma mark - UITextViewDelegate

- (BOOL) textField: (UITextField *) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString *) newCharacter
{
    
    NSUInteger oldLength = textField.text.length;
    NSUInteger newCharacterLength = newCharacter.length;
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = (oldLength + newCharacterLength) - rangeLength;
    
    
    self.currentSearchTerm = [NSMutableString stringWithString:[textField.text uppercaseString]];
    if(oldLength < newLength)
        [self.currentSearchTerm appendString:[newCharacter uppercaseString]];
    else
        [self.currentSearchTerm deleteCharactersInRange:NSMakeRange(self.currentSearchTerm.length - 1, 1)];
    
    
    [self.friendsCollectionView reloadData];
    
    return YES;
}

#pragma mark - Button Delegates

-(IBAction)facebookButtonPressed:(id)sender
{
    
}
-(IBAction)twitterButtonPressed:(id)sender
{
    
}
-(IBAction)emailButtonPressed:(id)sender
{
    
}

-(IBAction)authorizeFacebookButtonPressed:(id)sender
{
    
}
-(IBAction)authorizeAddressBookButtonPressed:(id)sender
{
    [self requestAddressBookAuthorization];
}

@end
