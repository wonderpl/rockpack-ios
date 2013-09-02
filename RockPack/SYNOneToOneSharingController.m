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

@end

@implementation SYNOneToOneSharingController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.messageTextView.font = [UIFont rockpackFontOfSize:self.messageTextView.font.pointSize];
    
    self.searchTextField.font = [UIFont rockpackFontOfSize:self.searchTextField.font.pointSize];
    
    
    
    switch (ABAddressBookGetAuthorizationStatus())
    {
        case kABAuthorizationStatusAuthorized:
            
            break;
            
        case kABAuthorizationStatusDenied:
            
            break;
            
        case kABAuthorizationStatusNotDetermined:
            
            break;
            
        case kABAuthorizationStatusRestricted:
            
            break;
    }
    
    
}

-(void)getDataFromAddressBook
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    
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
}

@end
