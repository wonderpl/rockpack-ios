    //
//  SYNOneToOneSharingController.m
//  rockpack
//
//  Created by Michael Michailidis on 28/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "Friend.h"
#import "OWActivities.h"
#import "OWActivityView.h"
#import "OWActivityViewController.h"
#import "RegexKitLite.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNFacebookManager.h"
#import "SYNFriendThumbnailCell.h"
#import "SYNOneToOneFriendCell.h"
#import "SYNOneToOneSharingController.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "VideoInstance.h"
#import "SYNAppDelegate.h"
#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define kOneToOneSharingViewId	  @"kOneToOneSharingViewId"
#define kNumberOfEmptyRecentSlots 5


@interface SYNOneToOneSharingController () <UICollectionViewDataSource,
                                            UICollectionViewDelegate,
                                            UITextFieldDelegate,
                                            UITableViewDataSource,
                                            UITableViewDelegate,
                                            UIScrollViewDelegate>

@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loader;
@property (nonatomic, strong) IBOutlet UIButton *authorizeFacebookButton;
@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) IBOutlet UICollectionView *recentFriendsCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *searchFieldFrameImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *shareLabel;
@property (nonatomic, strong) IBOutlet UITableView *searchResultsTableView;
@property (nonatomic, strong) IBOutlet UITextField *searchTextField;
@property (nonatomic, strong) IBOutlet UILabel * facebookLabel;
@property (nonatomic, strong) IBOutlet UIView *activitiesContainerView;

@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSArray *recentFriends;

@property (nonatomic, readonly) NSArray *searchedFriends;

@property (nonatomic, strong) NSCache *addressBookImageCache;
@property (nonatomic, strong) NSMutableString *currentSearchTerm;
@property (nonatomic, strong) UIImage *imageToShare;
@property (nonatomic, weak) Friend *friendToAddEmail;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* facebookLoader;
@property (strong, nonatomic) NSMutableDictionary *mutableShareDictionary;
@property (strong, nonatomic) OWActivityViewController *activityViewController;
@property (nonatomic) BOOL hasAttemptedToLoadData;

@end


@implementation SYNOneToOneSharingController

@synthesize hasAttemptedToLoadData;


- (id) initWithInfo: (NSMutableDictionary *) mutableShareDictionary
{
    if (self = [super initWithNibName: @"SYNOneToOneSharingController"
                               bundle: nil])
    {
        self.mutableShareDictionary = mutableShareDictionary;
        hasAttemptedToLoadData = NO;
        
        
    }
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.loader hidesWhenStopped];
    self.facebookLoader.hidden = YES;
    
    self.friends = [NSMutableArray array];
    self.recentFriends = [NSArray array];
    
    self.addressBookImageCache = [[NSCache alloc] init];
    
    self.currentSearchTerm = [[NSMutableString alloc] init];
    
    self.closeButton.hidden = YES;
     
    self.searchTextField.font = [UIFont rockpackFontOfSize: self.searchTextField.font.pointSize];
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
    self.shareLabel.font = [UIFont rockpackFontOfSize: self.titleLabel.font.pointSize];
    
    [self.recentFriendsCollectionView registerNib: [UINib nibWithNibName: @"SYNFriendThumbnailCell" bundle: nil]
                       forCellWithReuseIdentifier: @"SYNFriendThumbnailCell"];
    
    self.searchFieldFrameImageView.image = [[UIImage imageNamed: @"FieldSearch"]
                                            resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f)];
    
    
    
    if (IS_IPHONE)
    {
        // resize for iPhone
        CGRect vFrame = self.view.frame;
        vFrame.size.width = 320.0f;
        
        self.view.frame = vFrame;
        
        CGRect cbFrame = self.closeButton.frame;
        cbFrame.origin.x = 278.0f;
        self.closeButton.frame = cbFrame;
    }
    
    self.originalFrame = CGRectZero;
    
    // Basic recognition
    self.loader.hidden = YES;
    
    
    
    BOOL canReadAddressBook = NO;
    
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusNotDetermined:
            DebugLog(@"AddressBook Status: Not Determined, asking for authorization");
            [self requestAddressBookAuthorization];
            break;
        case kABAuthorizationStatusDenied:
            DebugLog(@"AddressBook Status: Denied");
            break;
        case kABAuthorizationStatusRestricted:
            DebugLog(@"AddressBook Status: Restricted");
            break;
        case kABAuthorizationStatusAuthorized:
            DebugLog(@"AddressBook Status: Authorized, fetching contacts");
            [self fetchAddressBookFriends];
            canReadAddressBook = YES;
            break;
        default:
            break;
    }
    
    
    // if the user is FB connected try and pull his friends
    if ([[SYNFacebookManager sharedFBManager] hasActiveSession])
    {
        DebugLog(@"The user is FB connected, trying to pull friends from server");
        [self fetchAndDisplayFriends];
    }
    else
    {
        if(!canReadAddressBook)
        {
            self.searchTextField.placeholder = @"Type an email address";
        }
    }
    
    // always present the buttons at the bottom
    [self presentActivities];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    if (IS_IPHONE)
    {
        // resize for iPhone
        if (self.originalFrame.size.height != 0)
        {
            self.view.alpha = 0.0;
        }
    }
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    if (IS_IPHONE)
    {
        // resize for iPhone
        if (self.originalFrame.size.height != 0)
        {
            CGRect pvFrame = self.originalFrame;
            pvFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeightWithStatusBar] - pvFrame.size.height;
            self.view.frame = pvFrame;
            
            [UIView animateWithDuration: 0.2
                             animations: ^{
                                 self.view.alpha = 1.0;
                             }];
        }
    }
}


- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    self.originalFrame = self.view.frame;
}


-(void)showLoader:(BOOL)show
{
    if(show)
    {
        
        [self.loader startAnimating];
        self.loader.hidden = NO;
        self.recentFriendsCollectionView.hidden = YES;
    }
    else
    {
        [self.loader stopAnimating];
        self.loader.hidden = YES;
        self.recentFriendsCollectionView.hidden = NO;
    }
}





- (void) presentActivities
{
    
    // load activities
    OWFacebookActivity *facebookActivity = [[OWFacebookActivity alloc] init];
    OWTwitterActivity *twitterActivity = [[OWTwitterActivity alloc] init];
    
    NSMutableArray *activities = @[facebookActivity, twitterActivity].mutableCopy;
    
    if ([MFMailComposeViewController canSendMail])
    {
        OWMailActivity *mailActivity = [[OWMailActivity alloc] init];
        [activities addObject: mailActivity];
        
        // TODO: We might want to disable the email icon here if we don't have email on this device (iPod touch or non-configured email)
    }
    
    CGRect aViewFrame = CGRectZero;
    aViewFrame.size = self.activitiesContainerView.frame.size;
    
    self.activityViewController = [[OWActivityViewController alloc] initWithViewController: self
                                                                                activities: activities];
    
    self.activityViewController.userInfo = self.mutableShareDictionary;
    
    [self.activitiesContainerView addSubview: self.activityViewController.view];
}


- (void) requestAddressBookAuthorization
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (addressBookRef == NULL)
        return;
    
    
    BOOL hasFacebookSession = [[SYNFacebookManager sharedFBManager] hasActiveSession];
    
    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
                           if (granted)
                           {
                               NSLog(@"Address Book Access GRANTED");
                               
                               // saves the address book friends in the DB
                               [self fetchAddressBookFriends];
                               
                               // populates the self.friends array with possibly new data
                               [self fetchAndDisplayFriends];
                               
                               
                           }
                           else
                           {
                               NSLog(@"Address Book Access DENIED");
                               
                               if (!hasFacebookSession)
                               {
                                   
                               }
                           }
                           
                           CFRelease(addressBookRef);

                       });
          });
}





#pragma mark - Data Retrieval



-(void)fetchAndDisplayFriends
{
    __weak SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    __weak SYNOneToOneSharingController *weakSelf = self;
    
    NSError *error;
    NSArray *existingFriendsArray;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"Friend"
                                         inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    
    
    existingFriendsArray = [appDelegate.searchManagedObjectContext executeFetchRequest: fetchRequest
                                                                                 error: &error];
    
    
    if(!error)
    {
        //NSLog(@"Friends Found %@:", hasAttemptedToLoadData ? @"AFTER loading data from server" : @"BEFORE laoding data from server");
        
        [self.friends removeAllObjects];
        
        NSMutableArray* recentlySharedFriendsMutableArray = [NSMutableArray arrayWithCapacity:existingFriendsArray.count]; // maximum
        for (Friend* existingFriend in existingFriendsArray)
        {
            [self.friends addObject:existingFriend];
            
            if(existingFriend.lastShareDate)
                [recentlySharedFriendsMutableArray addObject:existingFriend];
            
            
        }
        
        // sort by date
        
        
        self.recentFriends = [recentlySharedFriendsMutableArray sortedArrayUsingComparator:^NSComparisonResult(Friend* friendA, Friend* friendB) {
                                
                                return [friendB.lastShareDate compare:friendA.lastShareDate];
        }];
        
        [self.recentFriendsCollectionView reloadData];
    }
    
    
    
    if(hasAttemptedToLoadData) // to avoid infinite recursion
        return;
    
    
    
    [weakSelf showLoader:YES];
    
    [appDelegate.oAuthNetworkEngine friendsForUser: appDelegate.currentUser
                                        onlyRecent: NO
                                 completionHandler: ^(id dictionary) {
                                     
                                     
                                     if([appDelegate.searchRegistry registerFriendsFromDictionary:dictionary])
                                     {
                                         [weakSelf fetchAndDisplayFriends];
                                     }
                                     else
                                     {
                                         DebugLog(@"There was a problem loading friends");
                                     }
                                     
                                     [weakSelf showLoader:NO];
                                     
                                     hasAttemptedToLoadData = YES;
                                     
                                     [self.recentFriendsCollectionView reloadData];
                                     
                                 } errorHandler: ^(id dictionary) {
                                     
                                     [weakSelf showLoader:NO];
                                     
                                     hasAttemptedToLoadData = YES;
                                     
                                     [weakSelf.recentFriendsCollectionView reloadData];
                                 }];
    
}

- (void) fetchAddressBookFriends
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (addressBookRef == NULL)
        return;
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSArray *arrayOfAddressBookContacts = (__bridge_transfer NSArray *) ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    
    self.addressBookImageCache  = [appDelegate.searchRegistry registerFriendsFromAddressBookArray:arrayOfAddressBookContacts];
    
    CFRelease(addressBookRef);
    
    if(self.addressBookImageCache) // if there is a cache (even if it's empty) then searchRegistry completed succesfully
        [self.recentFriendsCollectionView reloadData]; 
    else
        self.addressBookImageCache = [[NSCache alloc] init]; // keep a valid cache to avoid unexpecatble crashes
}


#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    // prevent the display of the "empty" recent cells before the friends have loaded
    // then allow for 5 extra slots to display the "empty" cells
    return (!hasAttemptedToLoadData ? 0 : 1 + self.recentFriends.count + kNumberOfEmptyRecentSlots);
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNFriendThumbnailCell *userThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNFriendThumbnailCell"
                                                                                          forIndexPath: indexPath];
    
    if(indexPath.item == 0)
    {
        userThumbnailCell.imageView.image = [UIImage imageNamed:@"ShareAddEntry.jpg"];
        [userThumbnailCell setDisplayName: @"Add new Email"];
        
        userThumbnailCell.imageView.alpha = 1.0f;
        
        userThumbnailCell.shadowImageView.alpha = 1.0f;
    }
    else if (indexPath.item - 1 < self.recentFriends.count)
    {
        Friend *friend = self.recentFriends[indexPath.item - 1];
        
        NSString* nameToDisplay;
        if(friend.displayName && ![friend.displayName isEqualToString:@""])
            nameToDisplay = friend.displayName;
        else if (friend.email && ![friend.email isEqualToString:@""])
            nameToDisplay = friend.email;
        else
            nameToDisplay = @"";
        
        if ([friend.thumbnailURL hasPrefix: @"cached://"]) // cached from address book image
        {
            NSPurgeableData *pdata = [self.addressBookImageCache objectForKey: friend.thumbnailURL];
            
            UIImage *img;
            
            if (!pdata || !(img = [UIImage imageWithData: pdata]))
            {
                img = [UIImage imageNamed: @"ABContactPlaceholder"];
            }
            
            userThumbnailCell.imageView.image = img;
        }
        else if([friend.thumbnailURL hasPrefix:@"http"]) // includes https of course
        {
            [userThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: friend.thumbnailLargeUrl]
                                        placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
                                                 options: SDWebImageRetryFailed];
        }
        else
        {
            userThumbnailCell.imageView.image = [UIImage imageNamed:@"PlaceholderAvatarChannel"];
        }
        
        [userThumbnailCell setDisplayName: nameToDisplay];
        
        userThumbnailCell.imageView.alpha = 1.0f;
        
        userThumbnailCell.shadowImageView.alpha = 1.0f;
        
    }
    else // on the fake slots (stubs)
    {
        userThumbnailCell.imageView.image = [UIImage imageNamed: @"RecentContactPlaceholder"];
        userThumbnailCell.nameLabel.text = @"Recent";
        // userThumbnailCell.backgroundColor = [UIColor redColor];
        
        CGFloat factor = 1.0f - ((float) ((indexPath.row - 1) - self.recentFriends.count) / (float) kNumberOfEmptyRecentSlots);
        // fade slots
        userThumbnailCell.imageView.alpha = factor;
        userThumbnailCell.shadowImageView.alpha = factor;
    }
    
    return userThumbnailCell;
}


- (BOOL) collectionView: (UICollectionView *) collectionView
         shouldSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    // "Recent" stub cells are not clickable...
    
    return (indexPath.item <= self.recentFriends.count);
}


- (void)collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    // it will (should) only be called for indexPath.item - 1 < self.recentFriends.count so it will exclude stub cells
    
    if(indexPath.item == 0) // first cell
    {
        [self presentAlertToFillEmailForFriend:nil];
        return;
    }
    
    Friend *friend = self.recentFriends[indexPath.row - 1];
    
    if ([friend.externalSystem isEqualToString: kEmail])
    {
        [self sendEmailToFriend: friend];
    }
    else if ([friend.externalSystem isEqualToString: kFacebook])
    {
        // do facebook stuff
    }
}


#pragma mark - UITableView Delegate/Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.searchedFriends.count + 1; // for add new email
}


- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    SYNOneToOneFriendCell *cell = [tableView dequeueReusableCellWithIdentifier: @"SYNOneToOneFriendCell"];
    
    if (cell == nil)
    {
        cell = [[SYNOneToOneFriendCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                            reuseIdentifier: @"SYNOneToOneFriendCell"];
    }
    
    if (indexPath.row == self.searchedFriends.count) // last 'special' cell
    {
        
        cell.imageView.image = [UIImage imageNamed: @"ShareAddEntrySmall.jpg"];
        cell.textLabel.text = @"Add a new email address";
        cell.detailTextLabel.text = @"";
        cell.special = YES;
        return cell;
    }
    
    cell.special = NO;
    
    Friend *friend = self.searchedFriends[indexPath.row];
    cell.textLabel.text = friend.displayName;
    
    
    cell.detailTextLabel.text = [self isValidEmail: friend.email] ? friend.email : @"Pick and email address";
    
    // image
    
    if ([friend.thumbnailURL hasPrefix: @"http"]) // good for http and https
    {
        [cell.imageView setImageWithURL: [NSURL URLWithString: friend.thumbnailLargeUrl]
                       placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
                                options: SDWebImageRetryFailed];
    }
    else if ([friend.thumbnailURL hasPrefix: @"cached://"])                   // has been cached from the address book access
    {
        NSPurgeableData *pdata = [self.addressBookImageCache objectForKey: friend.thumbnailURL];
        
        UIImage *img;
        
        if (!pdata || !(img = [UIImage imageWithData: pdata]))
        {
            img = [UIImage imageNamed: @"ABContactPlaceholder"];
        }
        
        cell.imageView.image = img;
    }
    else
    {
        
    }
    
    return cell;
}


- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath;
{
    return 50.0f;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    Friend *friend;
    
    
    if (indexPath.row < self.searchedFriends.count)
    {
        friend = self.searchedFriends[indexPath.row];
        
        if ([self isValidEmail: friend.email]) // has a valid email
            [self sendEmailToFriend: friend];
        
        else // no email
            [self presentAlertToFillEmailForFriend:friend];
        
    }
    else // last cell pressed
    {
        [self presentAlertToFillEmailForFriend:nil];
    }
     
    
    
    [tableView removeFromSuperview];
}


#pragma mark - UIAlertViewDelegate

-(void) presentAlertToFillEmailForFriend:(Friend*)friend
{
    // create friend on the fly
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *titleText;
    if(!friend) // possibly by pressing the 'add new email' cell
    {
        friend = [Friend insertInManagedObjectContext: appDelegate.searchManagedObjectContext];
        friend.externalSystem = @"email";
        
        titleText = @"Enter a New Email";
    }
    else
    {
        titleText = [NSString stringWithFormat: @"Enter an Email for %@", friend.firstName];
    }
    
    self.friendToAddEmail = friend;
    
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle: titleText
                                                     message: @"We'll send this channel to their email."
                                                    delegate: self
                                           cancelButtonTitle: @"Cancel"
                                           otherButtonTitles: @"Send", nil];
    
    prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
    prompt.delegate = self;
    
    if([self isValidEmail:self.currentSearchTerm])
    {
        UITextField *textField = [prompt textFieldAtIndex:0];
        [textField setText:self.currentSearchTerm];
    }
    
    [prompt show];
}

- (BOOL) alertViewShouldEnableFirstOtherButton: (UIAlertView *) alertView
{
    UITextField *textfield = [alertView textFieldAtIndex: 0];
    
    return [self isValidEmail: textfield.text];
}


- (void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex
{
    if (buttonIndex == 0) // cancel button pressed
    {
        return;
    }
    
    UITextField *textfield = [alertView textFieldAtIndex: 0];
    
    // search if friend already exists by his email
    for (Friend* f in self.friends)
    {
        if([f.email isEqualToString:textfield.text])
        {
            self.friendToAddEmail = nil;
            [self sendEmailToFriend:f];
            return;
        }
        
    }
    
    self.friendToAddEmail.email = textfield.text;
    if([self.friendToAddEmail.externalSystem isEqualToString:kEmail])
    {
        self.friendToAddEmail.externalUID = self.friendToAddEmail.email; // workaround the fact that we do not have a UID for this new user
    }
    
    
    [self sendEmailToFriend: self.friendToAddEmail];
}


#pragma mark - UITextFieldDelegate

- (BOOL) textField: (UITextField *) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString *) newCharacter
{
    NSUInteger oldLength = textField.text.length;
    NSUInteger newCharacterLength = newCharacter.length;
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = (oldLength + newCharacterLength) - rangeLength;
    
    self.currentSearchTerm = [NSMutableString stringWithString: [textField.text uppercaseString]];
    
    if (oldLength < newLength)
    {
        [self.currentSearchTerm appendString: [newCharacter uppercaseString]];
    }
    else
    {
        [self.currentSearchTerm deleteCharactersInRange: NSMakeRange(self.currentSearchTerm.length - 1, 1)];
    }
    
    
    
    
    [self.searchResultsTableView reloadData];
    
    return YES;
}

-(NSArray*)searchedFriends
{
    
    if (self.currentSearchTerm.length > 0)
    {
        NSPredicate *searchPredicate = [NSPredicate predicateWithBlock: ^BOOL (Friend *friend, NSDictionary *bindings) {
            // either first or last name matches
            return ([[friend.firstName uppercaseString] hasPrefix: self.currentSearchTerm]) ||
                    ([[friend.lastName uppercaseString] hasPrefix: self.currentSearchTerm]);
        }];
        
        return [self.friends filteredArrayUsingPredicate: searchPredicate];
    }
    else
    {
        return self.friends;
    }
}


- (BOOL) textFieldShouldBeginEditing: (UITextField *) textField
{
    self.currentSearchTerm = [NSMutableString stringWithString:@""];
    
    CGRect sResTblFrame = self.searchResultsTableView.frame;
    
    sResTblFrame.origin.y = 104.0f;
    sResTblFrame.size.height = self.view.frame.size.height - sResTblFrame.origin.y;
    
    self.searchResultsTableView.frame = sResTblFrame;

    [self.view addSubview: self.searchResultsTableView];
    
    [self.searchResultsTableView reloadData];
    
    self.closeButton.hidden = NO;
    self.closeButton.alpha = 0.0f;
    
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         CGRect vFrame = self.view.frame;
                         vFrame.origin.y -= 160.0f;
                         self.view.frame = vFrame;
                         
                         self.closeButton.alpha = 1.0f;
                         
                         CGRect sfFrame = self.searchFieldFrameImageView.frame;
                         sfFrame.size.width -= 30.0f;
                         self.searchFieldFrameImageView.frame = sfFrame;
                     }
                     completion: nil];
    
    
    return YES;
}


- (void) textFieldDidEndEditing: (UITextField *) textField
{
    [UIView animateWithDuration: 0.2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         CGRect vFrame = self.view.frame;
                         vFrame.origin.y += 160.0f;
                         self.view.frame = vFrame;
                         
                         
                         self.closeButton.alpha = 0.0f;
                         
                         CGRect sfFrame = self.searchFieldFrameImageView.frame;
                         sfFrame.size.width += 30.0f;
                         self.searchFieldFrameImageView.frame = sfFrame;
                     }
                     completion:^(BOOL finished) {
                         
                         self.closeButton.hidden = YES;
                         
                         
                         
                         
                     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchTextField resignFirstResponder];
    
    return YES;
}

#pragma mark - UIScrollView Delegate


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if(scrollView == self.searchResultsTableView)
//    {
//        [self.searchTextField resignFirstResponder];
//    }
}

#pragma mark - Button Delegates

- (IBAction) closeButtonPressed: (id) sender
{
    self.searchTextField.text = @"";
    [self.searchResultsTableView removeFromSuperview];
    [self.searchTextField resignFirstResponder];
    self.closeButton.hidden = YES;
}


- (IBAction) authorizeFacebookButtonPressed: (UIButton*) button
{
    
    button.hidden = YES;
    self.facebookLoader.hidden = NO;
    [self.facebookLoader startAnimating];
    __weak SYNAppDelegate* weakAppDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    SYNFacebookManager* facebookManager = [SYNFacebookManager sharedFBManager];
    
    [facebookManager loginOnSuccess: ^(NSDictionary<FBGraphUser> *dictionary) {
        
        FBAccessTokenData* accessTokenData = [[FBSession activeSession] accessTokenData];
        
        [weakAppDelegate.oAuthNetworkEngine connectFacebookAccountForUserId:weakAppDelegate.currentUser.uniqueId
                                                         andAccessTokenData:accessTokenData
                                                          completionHandler:^(id no_responce) {
                                                              
                                                              
                                                              [self fetchAndDisplayFriends];
                                                              
                                                              self.facebookLoader.hidden = YES;
                                                              [self.facebookLoader stopAnimating];
                                                              
                                                              button.hidden = NO;
                                                              
                                                          } errorHandler:^(id error) {
                                                              
                                                              button.hidden = NO;
                                                              self.facebookLoader.hidden = YES;
                                                              [self.facebookLoader stopAnimating];
                                                              NSString* message;
                                                              if([error isKindOfClass:[NSDictionary class]] &&
                                                                 (message = error[@"message"]))
                                                              {
                                                                  
                                                                  if ([message isEqualToString:@"External account mismatch"])
                                                                  {
                                                                      self.facebookLabel.text = @"Log in failed. This account seems to be associated with a different User.";
                                                                  }
                                                                  
                                                              }
                                                              
                                                              [[SYNFacebookManager sharedFBManager] logoutOnSuccess:^{
                                                                  
                                                              } onFailure:^(NSString *errorMessage) {
                                                                  
                                                              }];
                                                              
                                                          }];
        
        
    } onFailure: ^(NSString* errorString) {
        
        self.facebookLabel.text = @"Log in with Facebook was cancelled.";
        self.facebookLoader.hidden = YES;
        [self.facebookLoader stopAnimating];
        button.hidden = NO;
        
    }];
}




#pragma mark - Helper Methods

- (BOOL) isValidEmail: (NSString *) emailCandidate
{
    return [emailCandidate isMatchedByRegex: @"^([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})$"];
}


- (void) sendEmailToFriend: (Friend *) friend
{
    self.view.userInteractionEnabled = NO;
    
    [self showLoader:YES];
    
    [self.searchTextField resignFirstResponder];
    
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    __weak SYNOneToOneSharingController *wself = self;
     
    [appDelegate.oAuthNetworkEngine emailShareWithObjectType: self.mutableShareDictionary[@"type"]
                                                    objectId: self.mutableShareDictionary[@"object_id"]
                                                  withFriend: friend
                                           completionHandler: ^(id no_content) {
                                               
                                               
                                               friend.lastShareDate = [NSDate date]; // update the date
                                               
                                               Friend* foundFriend;
                                               for (Friend* f in self.friends)
                                                   if([f.email isEqualToString:friend.email])
                                                       foundFriend = f;
                                               
                                               
                                               if(!foundFriend)
                                               {
                                                   [self.friends addObject:friend];
                                                   
                                                   NSError* error;
                                                   [friend.managedObjectContext save:&error];
                                               }
                                               
                                              
                                               wself.friendToAddEmail = nil;
                                               
                                               wself.view.userInteractionEnabled = YES;
                                               
                                               [self fetchAndDisplayFriends];
                                               
                                               [self showLoader:NO];
                                               
                                               [appDelegate.viewStackManager presentSuccessNotificationWithMessage:@"Email Sent Succesfully"];
                                               
                                           } errorHandler: ^(NSDictionary *error) {
                                               
                                               NSString *title = @"Email Couldn't be Sent";
                                               NSString *reason = @"Unkown reson";
                                               NSDictionary *formErrors = error[@"form_errors"];
                                               
                                               if (formErrors[@"email"])
                                               {
                                                   reason = @"The email could be wrong or the service down.";
                                                   
                                               }
                                               
                                               if (formErrors[@"external_system"])
                                               {
                                                   reason = @"The email could be wrong or the service down.";
                                               }
                                               
                                               if (formErrors[@"object_id"])
                                               {
                                                   reason = @"The email could be wrong or the service down.";
                                               }
                                               
                                               UIAlertView *prompt = [[UIAlertView alloc] initWithTitle: title
                                                                                                message: reason
                                                                                               delegate: self
                                                                                      cancelButtonTitle: @"OK"
                                                                                      otherButtonTitles: nil];
                                               
                                               [prompt show];
                                               
                                               friend.email = nil;
                                               
                                               wself.friendToAddEmail = nil;
                                               
                                               [self showLoader:NO];
                                               
                                               self.view.userInteractionEnabled = YES;
                                           }];
}



@end
