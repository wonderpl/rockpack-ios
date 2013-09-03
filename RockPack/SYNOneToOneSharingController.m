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
#import "OWActivities.h"
#import "OWActivityViewController.h"

#import "OWActivityView.h"
#import <objc/runtime.h>

#define kOneToOneSharingViewId @"kOneToOneSharingViewId"

static char* friend_share_key = "SYNFriendThumbnailCell to Friend Share";

@interface SYNOneToOneSharingController () <UICollectionViewDataSource, UICollectionViewDelegate,
                                            UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITextView* messageTextView;
@property (nonatomic, strong) IBOutlet UITextField* searchTextField;
@property (nonatomic, strong) IBOutlet UICollectionView* recentFriendsCollectionView;
@property (strong, nonatomic) NSMutableDictionary *mutableShareDictionary;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* loader;
@property (strong, nonatomic) OWActivityViewController *activityViewController;

// second View

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UIButton* authorizeFacebookButton;
@property (nonatomic, strong) IBOutlet UIButton* authorizeAddressBookButton;

@property (nonatomic, strong) IBOutlet UITableView* searchResultsTableView;

@property (nonatomic, strong) IBOutlet UIView* activitiesContainerView;


@property (nonatomic, strong) NSArray* friends;
@property (nonatomic, strong) NSArray* recentFriends;
@property (nonatomic, strong) NSArray* searchedFriends;

@property (nonatomic, strong) IBOutlet UIView* authorizationView;

@property (nonatomic, strong) NSMutableString* currentSearchTerm;

@property (nonatomic, readonly) BOOL isInAuthorizationScreen;
@property (nonatomic, strong) NSString* resourceTypeToShare;

@end

@implementation SYNOneToOneSharingController

@synthesize friends;
@synthesize recentFriends;
@synthesize searchedFriends;
@synthesize currentSearchTerm;


-(id)initWithResourceType:(NSString*)rtype
{
    if (self = [super initWithNibName:@"SYNOneToOneSharingController" bundle:nil])
    {
        self.resourceTypeToShare = rtype;
    }
    return self;
}

+(id)withResourceType:(NSString*)rtype
{
    return [[self alloc] initWithResourceType:rtype];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.loader hidesWhenStopped];
    
    friends = [NSArray array];
    recentFriends = [NSArray array];
    searchedFriends = [NSArray array];
    
    currentSearchTerm = [[NSMutableString alloc] init];
    
    self.messageTextView.font = [UIFont rockpackFontOfSize:self.messageTextView.font.pointSize];
    
    self.searchTextField.font = [UIFont rockpackFontOfSize:self.searchTextField.font.pointSize];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize:self.titleLabel.font.pointSize];
    
    
    

}

 
-(BOOL)isInAuthorizationScreen
{
    return (BOOL)(self.authorizationView.superview != nil);
}


-(void)viewWillAppear:(BOOL)animated
{
    // Basic recognition
    
    self.loader.hidden = YES;
    
    BOOL hasFacebookSession = [[SYNFacebookManager sharedFBManager] hasActiveSession];
    ABAuthorizationStatus aBookAuthStatus = ABAddressBookGetAuthorizationStatus();
    
    if(aBookAuthStatus != kABAuthorizationStatusAuthorized)
    {
        // if it is the first time we are requesting authorization
        
        if(aBookAuthStatus == kABAuthorizationStatusNotDetermined)
        {
            
            // request authorization
            
            [self requestAddressBookAuthorization];
        }
        
        // in the meantime...
        
        
        if(!hasFacebookSession) // if there is neither a FB account
        {
            // present view with the two buttons
            
            [self presentAuthorizationScreen];
        }
        else
        {
            // load friends asynchronously and add them to the friends list when done
            [self fetchFriends];
            [self presentActivities];
        }
        
    }
    else // (status == kABAuthorizationStatusAuthorized)
    {
        // present main view
        
        [self fetchAddressBookFriends];
        
        if(hasFacebookSession)
        {
            
            // Pull up recently shared friends...
            [self fetchFriends];
        }
        
        [self presentActivities];
        
    }
   
    
}
-(void)presentActivities
{
    
    [self fetchFriends];
   
    // load activities
    
    NSString *userName = nil;
    NSString *subject = @"";
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    User *user = appDelegate.currentUser;
    
    if (user.fullNameIsPublicValue)
    {
        userName = user.fullName;
    }
    
    if (userName.length < 1)
    {
        userName = user.username;
    }
    
    if (userName != nil)
    {
        NSString *what = @"pack";
        
        if ([self.resourceTypeToShare isEqualToString:kVideo])
        {
            what = @"video";
        }
        
        subject = [NSString stringWithFormat: @"%@ has shared a %@ with you", userName, what];
    }
    

    
    self.mutableShareDictionary = @{   @"owner": @NO,
                                       @"video": @YES,
                                       @"subject": subject }.mutableCopy;
    // Only add image if we have one
    //    if (usingImage)
    //    {
    //        [self.mutableShareDictionary addEntriesFromDictionary: @{@"image": usingImage}];
    //    }
    
    OWFacebookActivity *facebookActivity = [[OWFacebookActivity alloc] init];
    OWTwitterActivity *twitterActivity = [[OWTwitterActivity alloc] init];
    
    
    NSMutableArray *activities = @[facebookActivity, twitterActivity].mutableCopy;
    
    if ([MFMailComposeViewController canSendMail])
    {
        OWMailActivity *mailActivity = [[OWMailActivity alloc] init];
        [activities addObject: mailActivity];
    }
    
    
    
    CGRect aViewFrame = CGRectZero;
    aViewFrame.size = self.activitiesContainerView.frame.size;
    
    self.activityViewController = [[OWActivityViewController alloc]	 initWithViewController: self
                                                                                 activities: activities];
    
    self.activityViewController.userInfo = self.mutableShareDictionary;
    
    [self.activitiesContainerView addSubview:self.activityViewController.view];
}
-(void)requestAddressBookAuthorization
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    if(addressBookRef == NULL)
        return;
    
    BOOL hasFacebookSession = [[SYNFacebookManager sharedFBManager] hasActiveSession];
    
    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
        
        if (granted)
        {
            NSLog(@"Address Book Access GRANTED");
            
            // populates the friends array
            [self fetchAddressBookFriends];
            
            // if in auth mode
            if(self.isInAuthorizationScreen)
            {
                [self.authorizationView removeFromSuperview];
            }
        }
        else
        {
            
            NSLog(@"Address Book Access DENIED");
            
            if(!hasFacebookSession)
            {
                [self presentAuthorizationScreen];
            }
            
        }
        
        CFRelease(addressBookRef);
         
    });
}
-(void)presentAuthorizationScreen
{
    CGRect aViewRect = self.authorizationView.frame;
    aViewRect.origin.y = 50.0f;
    self.authorizationView.frame = aViewRect;
    [self.view addSubview:self.authorizationView];
}


#pragma mark - Data Retrieval

-(void)fetchFriends
{
    
    __weak SYNOneToOneSharingController* weakSelf = self;
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.loader.hidden = NO;
    [self.loader startAnimating];
    
    [appDelegate.oAuthNetworkEngine friendsForUser:appDelegate.currentUser recent:NO completionHandler:^(id dictionary) {
        
        NSDictionary* usersDictionary = dictionary[@"users"];
        if(!usersDictionary)
            return;
        
        NSArray* itemsDictionary = usersDictionary[@"items"];
        if(!itemsDictionary)
            return;
        
        NSInteger friendsCount = itemsDictionary.count;
        
        NSMutableArray* fbFriendsMutableArray = [NSMutableArray arrayWithArray:self.friends];
        NSMutableArray* rFriendsMutableArray = [NSMutableArray arrayWithCapacity:friendsCount]; // max
        
        for (NSDictionary* itemDictionary in itemsDictionary)
        {
            Friend* friend = [Friend instanceFromDictionary:itemDictionary
                                  usingManagedObjectContext:appDelegate.searchManagedObjectContext];
            
            if(!friend || !friend.hasIOSDevice) // filter for users with iOS devices only
                return;
            
            [fbFriendsMutableArray addObject:friend];
            
            // parse date for recent
            
            if(friend.lastShareDate)
            {
                [rFriendsMutableArray addObject:friend];
            }
            
        }
        
        weakSelf.friends = [NSArray arrayWithArray:fbFriendsMutableArray]; // already contains the original friends
        
        weakSelf.recentFriends = [NSArray arrayWithArray:rFriendsMutableArray];
        
        [self.loader stopAnimating];
        
        [self.recentFriendsCollectionView reloadData];
        
        
    } errorHandler:^(id dictionary) {
        
        [self.loader stopAnimating];
        
    }];
}

-(void)fetchAddressBookFriends
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    
    if(addressBookRef == NULL)
        return;
    
    NSArray *arrayOfAllPeople = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSInteger total = [arrayOfAllPeople count];
    NSString *firstName, *lastName;
    
    Friend* contactFriend;
    NSMutableArray* friendsArrayMut = [NSMutableArray arrayWithArray:self.friends];
    for (NSUInteger peopleCounter = 0; peopleCounter < total; peopleCounter++)
    {
        
        ABRecordRef currentPerson = (__bridge ABRecordRef)[arrayOfAllPeople objectAtIndex:peopleCounter];
        ABRecordID cid;
        if(!currentPerson || ((cid = ABRecordGetRecordID(currentPerson)) == kABRecordInvalidID))
            continue;
         
        
        firstName = (__bridge_transfer NSString *)ABRecordCopyValue(currentPerson, kABPersonFirstNameProperty);
        lastName = (__bridge_transfer NSString *)ABRecordCopyValue(currentPerson, kABPersonLastNameProperty);
        
        ABMultiValueRef emailAddressMultValue = ABRecordCopyValue(currentPerson, kABPersonEmailProperty);
        NSArray* emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailAddressMultValue);
        CFRelease(emailAddressMultValue);
        
        
        contactFriend = [Friend insertInManagedObjectContext: appDelegate.searchManagedObjectContext];
        contactFriend.viewId = kOneToOneSharingViewId;
        
        contactFriend.displayName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        contactFriend.email = emailAddresses.count > 0 ? emailAddresses[0] : nil;
        contactFriend.externalSystem = @"email";
        contactFriend.externalUID = [NSString stringWithFormat:@"%i", cid];
        
        [friendsArrayMut addObject:contactFriend];
    }
    
    self.friends = [NSArray arrayWithArray:friendsArrayMut]; // already contains the original friends
    
    CFRelease(addressBookRef);
    
}

#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    return recentFriends.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    Friend *friend = self.recentFriends[indexPath.row];
    
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


#pragma mark - UITableView Delegate/Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return searchedFriends.count;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    Friend* friend = searchedFriends[indexPath.row];
     
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OneToOneSearchFriendCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"OneToOneSearchFriendCell"];
    }
    
    cell.textLabel.text = friend.displayName;
    
    return cell;
    
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath;
{
    return 77.0;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    //Friend* friend = searchedFriends[indexPath.row];
    
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
    
    // if a search has actually been typed
    
    if(self.currentSearchTerm.length > 0)
    {
        NSPredicate* searchPredicate = [NSPredicate predicateWithBlock:^BOOL(Friend* friend, NSDictionary *bindings) {
            
            return [friend.firstName hasPrefix:self.currentSearchTerm];
        }];
        
        self.searchedFriends = [self.friends filteredArrayUsingPredicate:searchPredicate];
    }
    else
    {
        self.searchedFriends = self.friends;
    }
    
    
    [self.searchResultsTableView reloadData];
    
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
