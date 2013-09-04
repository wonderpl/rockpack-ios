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
#import "SYNFacebookManager.h"
#import "OWActivities.h"
#import "OWActivityViewController.h"
#import "VideoInstance.h"
#import "Channel.h" 
#import "AppConstants.h"
#import "OWActivityView.h"
#import "SYNDeviceManager.h"
#import "RegexKitLite.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

#define kOneToOneSharingViewId @"kOneToOneSharingViewId"
#define kNumberOfEmptyRecentSlots 5


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

@property (nonatomic, strong) NSCache* addressBookImageCache;

@property (nonatomic, strong) NSArray* friends;
@property (nonatomic, strong) NSArray* recentFriends;
@property (nonatomic, strong) NSArray* searchedFriends;
@property (nonatomic, weak) Friend* friendToAddEmail;

@property (nonatomic, strong) IBOutlet UIView* authorizationView;

@property (nonatomic, strong) NSMutableString* currentSearchTerm;

@property (nonatomic, readonly) BOOL isInAuthorizationScreen;
@property (nonatomic, strong) AbstractCommon* resourceToShare;

@property (nonatomic, strong) UIImage* imageToShare;

@property (nonatomic, readonly) BOOL isVideo;

@end

@implementation SYNOneToOneSharingController

@synthesize friends;
@synthesize recentFriends;
@synthesize searchedFriends;
@synthesize currentSearchTerm;


- (id) initWithResource: (AbstractCommon *) objectToShare andImage:(UIImage*)imageToShare
{
    if (self = [super initWithNibName: @"SYNOneToOneSharingController"
                               bundle: nil])
    {
        self.resourceToShare = objectToShare;
        self.imageToShare = imageToShare;
    }
    
    return self;
}


+ (id) withResourceType: (AbstractCommon *) objectToShare andImage:(UIImage*)imageToShare
{
    return [[self alloc] initWithResource: objectToShare andImage:(UIImage*)imageToShare];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.loader hidesWhenStopped];
    
    friends = [NSArray array];
    recentFriends = [NSArray array];
    searchedFriends = [NSArray array];
    
    self.addressBookImageCache = [[NSCache alloc] init];
    
    currentSearchTerm = [[NSMutableString alloc] init];
    
    self.messageTextView.font = [UIFont rockpackFontOfSize: self.messageTextView.font.pointSize];
    self.searchTextField.font = [UIFont rockpackFontOfSize: self.searchTextField.font.pointSize];
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
    
    [self.recentFriendsCollectionView registerNib:[UINib nibWithNibName:@"SYNFriendThumbnailCell" bundle:nil]
                       forCellWithReuseIdentifier:@"SYNFriendThumbnailCell"];
    
}


- (BOOL) isInAuthorizationScreen
{
    return (BOOL) (self.authorizationView.superview != nil);
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // Basic recognition
    self.loader.hidden = YES;
    
    BOOL hasFacebookSession = [[SYNFacebookManager sharedFBManager] hasActiveSession];
    ABAuthorizationStatus aBookAuthStatus = ABAddressBookGetAuthorizationStatus();
    
    if (aBookAuthStatus != kABAuthorizationStatusAuthorized)
    {
        // if it is the first time we are requesting authorization
        
        if (aBookAuthStatus == kABAuthorizationStatusNotDetermined)
        {
            // request authorization
            
            [self requestAddressBookAuthorization];
        }
        
        // in the meantime...
        
        if (!hasFacebookSession) // if there is neither a FB account
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
        
        if (hasFacebookSession)
        {
            // Pull up recently shared friends...
            [self fetchFriends];
        }
        
        [self presentActivities];
    }
}


- (void) presentActivities
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
    
    if ([self.resourceToShare isKindOfClass:[Channel class]])
    {
        if (!self.imageToShare)
        {
            // Capture screen image if we weren't passed an image in
            UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
            CGRect keyWindowRect = [keyWindow bounds];
            UIGraphicsBeginImageContextWithOptions(keyWindowRect.size, YES, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [keyWindow.layer renderInContext: context];
            UIImage *capturedScreenImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIInterfaceOrientation orientation = [SYNDeviceManager.sharedInstance orientation];
            
            switch (orientation)
            {
                case UIDeviceOrientationPortrait:
                    orientation = UIImageOrientationUp;
                    break;
                    
                case UIDeviceOrientationPortraitUpsideDown:
                    orientation = UIImageOrientationDown;
                    break;
                    
                case UIDeviceOrientationLandscapeLeft:
                    orientation = UIImageOrientationLeft;
                    break;
                    
                case UIDeviceOrientationLandscapeRight:
                    orientation = UIImageOrientationRight;
                    break;
                    
                default:
                    orientation = UIImageOrientationRight;
                    DebugLog(@"Unknown orientation");
                    break;
            }
            
            UIImage *fixedOrientationImage = [UIImage  imageWithCGImage: capturedScreenImage.CGImage
                                                                  scale: capturedScreenImage.scale
                                                            orientation: orientation];
            self.imageToShare = fixedOrientationImage;
        }
    }
    
    if (userName != nil)
    {
        NSString *what = @"pack";
        
        if (self.isVideo)
        {
            what = @"video";
        }
        
        subject = [NSString stringWithFormat: @"%@ has shared a %@ with you", userName, what];
    }
    
    self.mutableShareDictionary = @{@"owner" : @(self.isOwner),
                                    @"video" : @(self.isVideo),
                                    @"subject" : subject}.mutableCopy;
    if (self.imageToShare)
    {
        [self.mutableShareDictionary addEntriesFromDictionary: @{@"image": self.imageToShare}];
    }
    
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
    
    self.activityViewController = [[OWActivityViewController alloc] initWithViewController: self
                                                                                activities: activities];
    
    self.activityViewController.userInfo = self.mutableShareDictionary;
    
    [self.activitiesContainerView addSubview:self.activityViewController.view];
    
}

-(BOOL)isOwner
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    if([self.resourceToShare isKindOfClass:[Channel class]])
        return [((Channel*)self.resourceToShare).channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId];
    else
        return NO;
    
}

-(BOOL)isVideo
{
    return [self.resourceToShare isKindOfClass:[VideoInstance class]];
}

- (void) requestAddressBookAuthorization
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


- (void) presentAuthorizationScreen
{
    CGRect aViewRect = self.authorizationView.frame;
    
    aViewRect.origin.y = 50.0f;
    self.authorizationView.frame = aViewRect;
    [self.view
     addSubview: self.authorizationView];
}


#pragma mark - Data Retrieval

- (void) fetchFriends
{
    __weak SYNOneToOneSharingController *weakSelf = self;
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    self.loader.hidden = NO;
    [self.loader startAnimating];
    
    [appDelegate.oAuthNetworkEngine
     friendsForUser: appDelegate.currentUser
     recent: NO
     completionHandler: ^(id dictionary) {
         NSDictionary *usersDictionary = dictionary[@"users"];
         
         if (!usersDictionary)
         {
             return;
         }
         
         NSArray * itemsDictionary = usersDictionary[@"items"];
         
         if (!itemsDictionary)
         {
             return;
         }
         
         NSInteger friendsCount = itemsDictionary.count;
         
         NSMutableArray *fbFriendsMutableArray = [NSMutableArray arrayWithArray: self.friends];
         NSMutableArray *rFriendsMutableArray = [NSMutableArray arrayWithCapacity: friendsCount]; // max
         
         for (NSDictionary * itemDictionary in itemsDictionary)
         {
             Friend *friend = [Friend instanceFromDictionary: itemDictionary
                                   usingManagedObjectContext: appDelegate.searchManagedObjectContext];
             
             if (!friend || !friend.hasIOSDevice) // filter for users with iOS devices only
             {
                 return;
             }
             
             [fbFriendsMutableArray addObject: friend];
             
             // parse date for recent
             
             if (friend.lastShareDate)
             {
                 [rFriendsMutableArray addObject: friend];
             }
         }
         
         weakSelf.friends = [NSArray arrayWithArray: fbFriendsMutableArray]; // already contains the original friends
         
         weakSelf.recentFriends = [NSArray arrayWithArray: rFriendsMutableArray];
         
         [self.loader stopAnimating];
         self.loader.hidden = YES;
         
         [self.recentFriendsCollectionView reloadData];
     }
     errorHandler: ^(id dictionary) {
         [self.loader stopAnimating];
         self.loader.hidden = YES;
     }];
}


- (void) fetchAddressBookFriends
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (addressBookRef == NULL)
    {
        return;
    }
    
    NSArray *arrayOfAllPeople = (__bridge_transfer NSArray *) ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSInteger total = [arrayOfAllPeople count];
    NSString *firstName, *lastName;
    NSData *imageData;
    Friend *contactFriend;
    NSMutableArray *friendsArrayMut = [NSMutableArray arrayWithArray: self.friends];
    
    for (NSUInteger peopleCounter = 0; peopleCounter < total; peopleCounter++)
    {
        ABRecordRef currentPerson = (__bridge ABRecordRef) [arrayOfAllPeople objectAtIndex: peopleCounter];
        ABRecordID cid;
        
        if (!currentPerson || ((cid = ABRecordGetRecordID(currentPerson)) == kABRecordInvalidID))
        {
            continue;
        }
        
        firstName = (__bridge_transfer NSString *) ABRecordCopyValue(currentPerson, kABPersonFirstNameProperty);
        lastName = (__bridge_transfer NSString *) ABRecordCopyValue(currentPerson, kABPersonLastNameProperty);
        
        ABMultiValueRef emailAddressMultValue = ABRecordCopyValue(currentPerson, kABPersonEmailProperty);
        NSArray *emailAddresses = (__bridge NSArray *) ABMultiValueCopyArrayOfAllValues(emailAddressMultValue);
        CFRelease(emailAddressMultValue);
        
        imageData = (__bridge_transfer NSData *)ABPersonCopyImageData(currentPerson);
        
        contactFriend = [Friend insertInManagedObjectContext: appDelegate.searchManagedObjectContext];
        contactFriend.viewId = kOneToOneSharingViewId;
        contactFriend.uniqueId = [NSString stringWithFormat: @"%i", cid];
        contactFriend.displayName = [NSString stringWithFormat: @"%@ %@", firstName, lastName];
        contactFriend.email = emailAddresses.count > 0 ? emailAddresses[0] : nil;
        contactFriend.externalSystem = @"email";
        contactFriend.externalUID = [NSString stringWithFormat: @"%i", cid];
        
        if (imageData) {
         
            NSString* key = [NSString stringWithFormat:@"cached://%@", contactFriend.uniqueId];
            contactFriend.thumbnailURL = key;
            [self.addressBookImageCache setObject:imageData forKey:key];
        }
        
        [friendsArrayMut addObject: contactFriend];
    }
    
    self.friends = [NSArray arrayWithArray: friendsArrayMut]; // already contains the original friends
    
    CFRelease(addressBookRef);
    
    [self.recentFriendsCollectionView reloadData]; // in case we have found new images
}


#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    return recentFriends.count + kNumberOfEmptyRecentSlots; // slots for the recent fake items
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    
    SYNFriendThumbnailCell *userThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNFriendThumbnailCell"
                                                                                          forIndexPath: indexPath];
    
    if(indexPath.item < self.recentFriends.count)
    {
        Friend *friend = self.recentFriends[indexPath.row];
        userThumbnailCell.nameLabel.text = friend.displayName;
        
        if([friend.thumbnailURL hasPrefix:@"cached://"])
        {
            
            NSPurgeableData* pdata = [self.addressBookImageCache objectForKey:friend.thumbnailURL];
            
            UIImage* img;
            if(!pdata || !(img = [UIImage imageWithData:pdata]))
                img = [UIImage imageNamed: @"ABContactPlaceholder"];
            
            
            userThumbnailCell.imageView.image = img;
        }
        else
        {
            [userThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: friend.thumbnailLargeUrl]
                                        placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
                                                 options: SDWebImageRetryFailed];
        }
        
        
        [userThumbnailCell setDisplayName: friend.displayName];
        
        
    }
    else // on the fake slots
    {
        userThumbnailCell.imageView.image = [UIImage imageNamed:@"RecentContactPlaceholder"];
        userThumbnailCell.nameLabel.text = @"Recent";
        // userThumbnailCell.backgroundColor = [UIColor redColor];
        
        CGFloat factor = 1.0f - ((float)(indexPath.row - self.recentFriends.count) / (float)kNumberOfEmptyRecentSlots);
        // fade slots
        userThumbnailCell.imageView.alpha =  factor;
        userThumbnailCell.shadowImageView.alpha = factor;

    }
    
    
    
    return userThumbnailCell;
    
}

- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if(indexPath.item < self.recentFriends.count)
    {
        Friend *friend = self.recentFriends[indexPath.row];
        if([friend.externalSystem isEqualToString:kEmail])
        {
            [self sendEmailToFriend:friend];
        }
        else if([friend.externalSystem isEqualToString:kFacebook])
        {
            // do facebook stuff
            
        }
     
    }
    else // on the fake slots
    {
        // do nothing for the moment
    }
}


#pragma mark - UITableView Delegate/Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return searchedFriends.count + 1; // for add new email
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    
     
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OneToOneSearchFriendCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"OneToOneSearchFriendCell"];
    }
    
    cell.textLabel.font = [UIFont boldRockpackFontOfSize:12.0f];
    
    if(indexPath.row < searchedFriends.count)
    {
        Friend* friend = searchedFriends[indexPath.row];
        cell.textLabel.text = friend.displayName;
        if([self isValidEmail:friend.email])
        {
            cell.detailTextLabel.text = friend.email;
        }
        else
        {
            cell.detailTextLabel.text = @"Pick and email address";
        }
    }
    else // special add new email cell
    {
        cell.textLabel.text = @"Add a new email address";
    }
    
    
    
    return cell;
    
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath;
{
    return 77.0;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    Friend* friend;
    NSString* titleText = @"Enter a New Email";
    if(indexPath.row < searchedFriends.count)
    {
        friend = searchedFriends[indexPath.row];
        titleText = [NSString stringWithFormat:@"Enter an Email for %@", friend.firstName];
        
    }
    
    self.friendToAddEmail = friend;
    
    if([self isValidEmail:friend.email]) // has a valid email
    {
        // send email
        
        [self sendEmailToFriend:friend];
    }
    else // either no email or clicked on the last cell
    {
        if(!self.friendToAddEmail)
        {
            // create friend on the fly
            SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
            
            self.friendToAddEmail = [Friend insertInManagedObjectContext:appDelegate.searchManagedObjectContext];
            self.friendToAddEmail.externalSystem = @"email";
            
        }
        
        UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:titleText
                                                         message:@"We'll send this channel to their email."
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"Send", nil];
        
        prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
        prompt.delegate = self;
        [prompt show];
        
    }
    
}

#pragma mark - UIAlertViewDelegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    UITextField *textfield =  [alertView textFieldAtIndex: 0];
    
    return [self isValidEmail:textfield.text];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
        return;
    
    UITextField *textfield =  [alertView textFieldAtIndex: 0];
    
    self.friendToAddEmail.email = textfield.text;
    self.friendToAddEmail.externalUID = self.friendToAddEmail.email; // workaround the fact that we do not have a UID for this new user
    
    [self sendEmailToFriend:self.friendToAddEmail];
}

#pragma mark - UITextFieldDelegate

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
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    
    self.searchedFriends = self.friends;
    
    CGRect sResTblFrame = self.searchResultsTableView.frame;
    
    sResTblFrame.origin.y = 117.0f;
    sResTblFrame.origin.x = 20.0f;
    sResTblFrame.size.height = self.view.frame.size.height - sResTblFrame.origin.y;
    
    self.searchResultsTableView.frame = sResTblFrame;
    
    
    
    [self.view addSubview:self.searchResultsTableView];
    
    [self.searchResultsTableView reloadData];
    
    return NO;
}

#pragma mark - UITextViewDelegate

// to be implemented


#pragma mark - Button Delegates

-(IBAction)authorizeFacebookButtonPressed:(id)sender
{
    
}
-(IBAction)authorizeAddressBookButtonPressed:(id)sender
{
    [self requestAddressBookAuthorization];
}

#pragma mark - Helper Methods

-(BOOL)isValidEmail:(NSString*)emailCandidate
{
    if(!emailCandidate || ![emailCandidate isKindOfClass:[NSString class]])
        return NO;
    
    return [emailCandidate isMatchedByRegex: @"^([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})$"];
}

-(void)sendEmailToFriend:(Friend*)friend
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    __weak SYNOneToOneSharingController* wself = self;
    [appDelegate.oAuthNetworkEngine emailShareObject:self.resourceToShare
                                          withFriend:friend
                                   completionHandler:^(id no_content) {
                                       
                                       UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Email Sent!"
                                                                                        message:nil
                                                                                       delegate:self
                                                                              cancelButtonTitle:@"OK"
                                                                              otherButtonTitles:nil];
                                       [prompt show];
                                       
                                       wself.friendToAddEmail = nil;
                                       
                                   } errorHandler:^(NSDictionary* error) {
                                       
                                       NSString* title = @"Email Couldn't be Sent";
                                       NSString* reason = @"Unkown reson";
                                       NSDictionary* formErrors = error[@"form_errors"];
                                       if(formErrors[@"email"])
                                       {
                                           reason = @"The email could be wrong or the service down.";
                                       }
                                       if(formErrors[@"external_system"])
                                       {
                                           reason = @"The email could be wrong or the service down.";
                                       }
                                       if(formErrors[@"object_id"])
                                       {
                                           reason = @"The email could be wrong or the service down.";
                                       }
                                       
                                       UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:title
                                                                                        message:reason
                                                                                       delegate:self
                                                                              cancelButtonTitle:@"OK"
                                                                              otherButtonTitles:nil];
                                       
                                       
                                       [prompt show];
                                       
                                       wself.friendToAddEmail = nil;
                                   }];
}

@end
