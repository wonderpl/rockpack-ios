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


// second View

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UIButton* authorizeFacebookButton;
@property (nonatomic, strong) IBOutlet UIButton* authorizeAddressBookButton;

@property (nonatomic, strong) NSArray* friendsToShare;

@property (nonatomic, strong) IBOutlet UIView* authorizationView;

@property (nonatomic, strong) NSMutableString* currentSearchTerm;

@end

@implementation SYNOneToOneSharingController

@synthesize friendsToShare;
@synthesize currentSearchTerm;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    friendsToShare = [NSArray array];
    
    currentSearchTerm = [[NSMutableString alloc] init];
    
    self.messageTextView.font = [UIFont rockpackFontOfSize:self.messageTextView.font.pointSize];
    
    self.searchTextField.font = [UIFont rockpackFontOfSize:self.searchTextField.font.pointSize];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize:self.titleLabel.font.pointSize];
    
    switch (ABAddressBookGetAuthorizationStatus())
    {
        case kABAuthorizationStatusAuthorized:
            NSLog(@"Address Book Authorized");
            [self getDataFromAddressBook];
            break;
            
        case kABAuthorizationStatusDenied:
            NSLog(@"Address Book Denied");
            break;
            
        case kABAuthorizationStatusNotDetermined:
            NSLog(@"Address Book Not Determined");
            break;
            
        case kABAuthorizationStatusRestricted:
            NSLog(@"Address Book Restricted");
            break;
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
            [self getDataFromAddressBook];
        } else {
            
            NSLog(@"Access was not granted");
            
        }
        
        CFRelease(addressBookRef);
    });
}
-(void)getDataFromAddressBook
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    
    if(addressBookRef == NULL)
        return;
    
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
    
    self.friendsToShare = [NSArray arrayWithArray:friendsToShare];
    
    CFRelease(addressBookRef);
}

#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    return friendsToShare.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    Friend *friend = self.friendsToShare[indexPath.row];
    
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
