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


#define kOneToOneSharingViewId @"kOneToOneSharingViewId"

@interface SYNOneToOneSharingController ()

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



@property (nonatomic, strong) IBOutlet UIView* authorizationView;

@end

@implementation SYNOneToOneSharingController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    for (NSUInteger peopleCounter = 0; peopleCounter < total; peopleCounter++)
    {
        
        ABRecordRef currentPerson = (__bridge ABRecordRef)[arrayOfAllPeople objectAtIndex:peopleCounter];
        
        
        
        firstName = (__bridge_transfer NSString *)ABRecordCopyValue(currentPerson, kABPersonFirstNameProperty);
        lastName = (__bridge_transfer NSString *)ABRecordCopyValue(currentPerson, kABPersonLastNameProperty);
        emailAddress = (__bridge_transfer NSString *)ABRecordCopyValue(currentPerson, kABPersonEmailProperty);
        
        NSLog(@"Contact found: %@, %@, %@", firstName, lastName, emailAddress);
        
        contactFriend = [Friend insertInManagedObjectContext: appDelegate.searchManagedObjectContext];
        contactFriend.viewId = kOneToOneSharingViewId;
        
        
        
    }
    
    CFRelease(addressBookRef);
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
