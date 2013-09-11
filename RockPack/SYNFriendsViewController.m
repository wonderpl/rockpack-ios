//
//  SYNFriendsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 22/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFriendsViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNFacebookManager.h"
#import "ChannelOwner.h"
#import "SYNFriendThumbnailCell.h"
#import "UIImageView+WebCache.h"
#import "SYNAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SYNOAuthNetworkEngine.h"
#import "Friend.h"
#import "GAI.h"
#import "SYNFacebookManager.h"
#import "SYNSideNavigatorViewController.h"
#import <objc/runtime.h>

static char* friend_association_key = "SYNFriendThumbnailCell to Friend";

@interface SYNFriendsViewController () <UIScrollViewDelegate> {
    BOOL hasAttemptedToLoadData;
}

@property (nonatomic, strong) NSArray* friends;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@property (nonatomic) BOOL onRockpackFilterOn;
@property (nonatomic, strong) NSArray* displayFriends;
@property (nonatomic, weak) Friend* currentlySelectedFriend;
@property (nonatomic, strong) NSMutableString* currentSearchTerm;



//iPhone specific
@property (nonatomic, strong) IBOutlet UIView* searchContainer;
@property (weak, nonatomic) IBOutlet UIImageView *searchFieldBackground;
@property (weak, nonatomic) IBOutlet UIView *searchSlider;

@end

@implementation SYNFriendsViewController

@synthesize appDelegate;
@synthesize onRockpackFilterOn;
@synthesize displayFriends = _displayFriends;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    onRockpackFilterOn = NO;
    
    self.currentSearchTerm = [[NSMutableString alloc] init];
    
    [self.searchField setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    self.friends = [NSArray array];
    
    // Register Cells
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNFriendThumbnailCell"
                                             bundle: nil];
    
    [self.friendsCollectionView registerNib: thumbnailCellNib
                 forCellWithReuseIdentifier: @"SYNFriendThumbnailCell"];
    
    self.preLoginLabel.font = [UIFont rockpackFontOfSize:self.preLoginLabel.font.pointSize];
    
    [self.activityIndicator hidesWhenStopped];
    
    self.allFriendsButton.titleLabel.font = [UIFont rockpackFontOfSize: IS_IPAD ? 14.0f : 12.0f];
    self.allFriendsButton.contentEdgeInsets = UIEdgeInsetsMake(IS_IPAD ? 7.0f : 5.0, 0.0f, 0.0f, 0.0f);
    self.onRockpackButton.titleLabel.font = [UIFont rockpackFontOfSize: IS_IPAD ? 14.0f : 12.0f];
    self.onRockpackButton.contentEdgeInsets = UIEdgeInsetsMake(IS_IPAD ? 7.0f : 5.0, 0.0f, 0.0f, 0.0f);
    
    self.searchField.font = [UIFont rockpackFontOfSize: self.searchField.font.pointSize];
    
    if([[SYNFacebookManager sharedFBManager] hasActiveSession])
    {
        self.facebookLoginButton.hidden = YES;
        self.preLoginLabel.hidden = YES;
        self.friendsCollectionView.hidden = NO;
        self.activityIndicator.hidden = NO;
        
        self.onRockpackButton.hidden = NO;
        self.allFriendsButton.hidden = NO;
        
        [self fetchAndDisplayFriends];
        
        [GAI.sharedInstance.defaultTracker sendView: @"Friends All"];
    }
    else
    {
        self.onRockpackButton.hidden = YES;
        self.allFriendsButton.hidden = YES;
        self.facebookLoginButton.hidden = NO;
        self.preLoginLabel.hidden = NO;
        self.friendsCollectionView.hidden = YES;
        self.activityIndicator.hidden = YES;
        
        [GAI.sharedInstance.defaultTracker sendView: @"Friends Fb Connect"];
    }
    
    if(IS_IPHONE)
    {
        // iPhone specific setup
        
        //Resizing images
        UIImage* backgroundImageOff = [[UIImage imageNamed:@"SearchTab"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f)];
        UIImage* backgroundImageOn = [[UIImage imageNamed:@"SearchTabSelected" ]resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f)];
        UIImage* backgroundImageHighlighted = [[UIImage imageNamed:@"SearchTabHighlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f)];
        
        [self.onRockpackButton setBackgroundImage:backgroundImageOff forState:UIControlStateNormal];
        [self.onRockpackButton setBackgroundImage:backgroundImageOn forState:UIControlStateSelected];
        [self.onRockpackButton setBackgroundImage:backgroundImageHighlighted forState:UIControlStateHighlighted];
        
        [self.allFriendsButton setBackgroundImage:backgroundImageOff forState:UIControlStateNormal];
        [self.allFriendsButton setBackgroundImage:backgroundImageOn forState:UIControlStateSelected];
        [self.allFriendsButton setBackgroundImage:backgroundImageHighlighted forState:UIControlStateHighlighted];
        
        self.searchFieldBackground.image = [[UIImage imageNamed: @"FieldSearch"]
                                    resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f,20.0f, 0.0f, 20.0f)];
        
        //Push the search slider out to the right.
        CGRect searchSliderFrame = self.searchSlider.frame;
        searchSliderFrame.origin.x = searchSliderFrame.size.width;
        self.searchSlider.frame= searchSliderFrame;
        
        if (IS_IOS_7_OR_GREATER)
        {
            self.view.backgroundColor = [UIColor clearColor];
        }

    }
    
    if (IS_IPAD)
    {
        //Semi-transparent background for iOS7
        if (IS_IOS_7_OR_GREATER)
        {
            UIView * whiteBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.x, self.view.frame.size.width, 1024 - self.view.frame.origin.y)];
            whiteBackgroundView.backgroundColor = [UIColor colorWithWhite:255.0f/255.0f alpha:0.4];
            [self.view insertSubview:whiteBackgroundView atIndex:0];
        }
    }
}



-(IBAction)switchClicked:(UIButton*)tab
{
    if( tab.selected ) // do not re-select
        return;
    
    [self.searchField resignFirstResponder];
    
    if(tab == self.onRockpackButton) {
        self.allFriendsButton.selected = NO;
        [GAI.sharedInstance.defaultTracker sendView: @"Friends RP"];
    } else {
        self.onRockpackButton.selected = NO;
        [GAI.sharedInstance.defaultTracker sendView: @"Friends All"];
    }
        
    
    tab.selected = YES;
    
    [self.friendsCollectionView reloadData];
}


-(void)fetchAndDisplayFriends
{
    
    
    
    NSError *error;
    NSArray *existingFriendsArray;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"Friend"
                                         inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"externalSystem != %@", kEmail];
    
    existingFriendsArray = [appDelegate.searchManagedObjectContext executeFetchRequest: fetchRequest
                                                                                 error: &error];
    
    
    if(!error)
    {
   
        
        [self setTitleForFriendsTab:[NSString stringWithFormat:@"FACEBOOK FRIENDS (%i)", existingFriendsArray.count]
                     andRockpackTab:[NSString stringWithFormat:@"ON ROCKPACK (%i)", self.rockpackFriends.count]];
        
        
        
        self.friends = [NSArray arrayWithArray:existingFriendsArray];
        
        [self.allFriendsButton setSelected:YES];
        
        [self.friendsCollectionView reloadData];
    }
    
    
    if(hasAttemptedToLoadData)
        return;
    
    hasAttemptedToLoadData = YES;
    
    __weak SYNFriendsViewController* weakSelf = self;
    
    [weakSelf showLoader:YES];
    
    [appDelegate.oAuthNetworkEngine friendsForUser:appDelegate.currentUser
                                        onlyRecent:NO
                                 completionHandler:^(id dictionary) {
        
                                     if([appDelegate.searchRegistry registerFriendsFromDictionary:dictionary])
                                     {
                                         [weakSelf fetchAndDisplayFriends];
                                     }
                                     else
                                     {
                                         DebugLog(@"There was a problem loading friends");
                                     }
                                     
                                     
                                     [weakSelf showLoader:NO];
        
                                     
        
                                     [self fetchAndDisplayFriends];
        
        
                                 } errorHandler:^(id dictionary) {
                                     
                                     
                                     
                                     
                                     [weakSelf showLoader:NO];
                                     
        
                                 }];
}
-(void)showLoader:(BOOL)show
{
    if(show)
    {
        [self.activityIndicator startAnimating];
        
        self.onRockpackButton.hidden = YES;
        self.allFriendsButton.hidden = YES;
    }
    else
    {
        self.onRockpackButton.hidden = NO;
        self.allFriendsButton.hidden = NO;
        
        
        [self.activityIndicator stopAnimating];
    }
}
-(void)setTitleForFriendsTab:(NSString*)ftText andRockpackTab:(NSString*)rtText
{
    // set first tab
    [self.allFriendsButton setTitle:ftText forState:UIControlStateNormal];
    [self.allFriendsButton setTitle:ftText forState:UIControlStateHighlighted];
    [self.allFriendsButton setTitle:ftText forState:UIControlStateSelected];
    
    // set second tab
    [self.onRockpackButton setTitle:rtText forState:UIControlStateNormal];
    [self.onRockpackButton setTitle:rtText forState:UIControlStateHighlighted];
    [self.onRockpackButton setTitle:rtText forState:UIControlStateSelected];
}

-(IBAction)facebookLoginPressed:(id)sender
{
    self.activityIndicator.center = self.facebookLoginButton.center;
    
    [self.activityIndicator startAnimating];
    
    self.facebookLoginButton.hidden = YES;
    
    self.preLoginLabel.text = @"Logging In";
    
    //Weak variables to avoid block retain cycles
    __weak SYNFriendsViewController* weakSelf = self;
    __weak SYNAppDelegate* weakAppDelegate = appDelegate;
    
    SYNFacebookManager* facebookManager = [SYNFacebookManager sharedFBManager];
    
    
    [facebookManager loginOnSuccess: ^(NSDictionary<FBGraphUser> *dictionary) {
        
        FBAccessTokenData* accessTokenData = [[FBSession activeSession] accessTokenData];
        
        [weakAppDelegate.oAuthNetworkEngine connectFacebookAccountForUserId: appDelegate.currentUser.uniqueId
                                                         andAccessTokenData: accessTokenData
                                                          completionHandler: ^(id no_responce) {
                                                              
                                                              [weakSelf.activityIndicator stopAnimating];
                                                              
                                                              weakSelf.friendsCollectionView.hidden = NO;
                                                              weakSelf.preLoginLabel.hidden = YES;
                                                              weakSelf.facebookLoginButton.hidden = YES;
                                                              
                                                              weakSelf.onRockpackButton.hidden = NO;
                                                              weakSelf.allFriendsButton.hidden = NO;
                                                              
                                                              [weakSelf fetchAndDisplayFriends];
            
                                                          } errorHandler:^(id error) {
                                                              
                                                              [weakSelf.activityIndicator stopAnimating];
                                                              
                                                              weakSelf.facebookLoginButton.hidden = NO;
                                                              
                                                              weakSelf.preLoginLabel.text = @"We could not Log you in becuase this FB account seems to be associated with a different User.";
                                                              
                                                              [[SYNFacebookManager sharedFBManager] logoutOnSuccess:^{
                                                                  
                                                              } onFailure:^(NSString *errorMessage) {
                                                                  
                                                              }];
            
                                                          }];
        
        
    } onFailure: ^(NSString* errorString) {
        
        [weakSelf.activityIndicator stopAnimating];
        
        weakSelf.facebookLoginButton.hidden = NO;
        
        weakSelf.preLoginLabel.text = @"Log in with Facebook was cancelled.";
        
        
     }];

}

#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.displayFriends.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    Friend *friend = self.displayFriends[indexPath.row];
    
    SYNFriendThumbnailCell *userThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNFriendThumbnailCell"
                                                                                        forIndexPath: indexPath];
    
    userThumbnailCell.nameLabel.text = friend.displayName;
    
    
    [userThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: friend.thumbnailLargeUrl]
                                placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
                                         options: SDWebImageRetryFailed];
    
    [userThumbnailCell setDisplayName: friend.displayName];
    
    
    
    objc_setAssociatedObject(userThumbnailCell, friend_association_key, friend, OBJC_ASSOCIATION_ASSIGN);
    
    return userThumbnailCell;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchField resignFirstResponder];
}



#pragma mark - UITextViewDelegate

- (BOOL) textField: (UITextField *) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString *) newCharacter
{
    
    NSUInteger oldLength = textField.text.length;
    NSUInteger newCharacterLength = newCharacter.length;
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = (oldLength + newCharacterLength) - rangeLength;
    
    
    self.currentSearchTerm = [NSMutableString stringWithString:[self.searchField.text uppercaseString]];
    if(oldLength < newLength)
        [self.currentSearchTerm appendString:[newCharacter uppercaseString]];
    else
        [self.currentSearchTerm deleteCharactersInRange:NSMakeRange(self.currentSearchTerm.length - 1, 1)];
    
    
    [self.friendsCollectionView reloadData];
    
    return YES;
}

-(NSArray*)displayFriends
{
    
    if(self.onRockpackButton.selected)
    {
        _displayFriends = [self rockpackFriends];
        
        
    }
    else
    {
        _displayFriends = [self facebookFriends];
        
    }
    
    if(self.currentSearchTerm.length > 0)
    {
        NSPredicate* searchPredicate = [NSPredicate predicateWithBlock:^BOOL(Friend* friend, NSDictionary *bindings) {
            
            NSString* nameToCompare = [friend.displayName uppercaseString];
            
            BOOL result = [nameToCompare hasPrefix:self.currentSearchTerm];
            
            if(self.onRockpackButton.selected) // is on the second tab
            {
                result = result & friend.isOnRockpack;
            }
            
            
            return result;
        }];
        
        _displayFriends = [_displayFriends filteredArrayUsingPredicate:searchPredicate];
    }
    
    return _displayFriends;
    
    
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [self.searchField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.currentSearchTerm setString:@""];
    [self.friendsCollectionView reloadData];
    return YES;
}



- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    SYNFriendThumbnailCell* cellClicked = (SYNFriendThumbnailCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    cellClicked.selected = YES;
    
    self.currentlySelectedFriend = objc_getAssociatedObject(cellClicked, friend_association_key);
    
    if(!self.currentlySelectedFriend.isOnRockpack) // facebook friend, invite to rockpack
    {
        
        [[GAI sharedInstance].defaultTracker sendEventWithCategory: @"uiAction"
                                                        withAction: @"friendToInvite"
                                                         withLabel: nil
                                                         withValue: nil];
        
        [[SYNFacebookManager sharedFBManager] sendAppRequestToFriend:self.currentlySelectedFriend
                                                           onSuccess:^{
                                                               
                                                               [[GAI sharedInstance].defaultTracker sendEventWithCategory: @"goal"
                                                                                                               withAction: @"friendInvited"
                                                                                                                withLabel: nil
                                                                                                                withValue: nil];
                                                               
                                                               [appDelegate.viewStackManager removePopoverView];
                                                               
                                                           } onFailure:^(NSError *error) {
                                                               
                                                               [appDelegate.viewStackManager removePopoverView];
                                                               
                                                           }];
    }
    else // on rockpack, go to profile
    {
        ChannelOwner* friendAsChannelOwner = (ChannelOwner*)self.currentlySelectedFriend;
        
        
        
        
        appDelegate.viewStackManager.returnBlock = ^{
            [appDelegate.viewStackManager openSideNavigatorToIndex:kFriendsRowIndex];
        };
        [appDelegate.viewStackManager viewProfileDetails:friendAsChannelOwner];
        
    }
    
    [self.searchField resignFirstResponder];
    
}

-(IBAction)inviteButtonPressed:(id)sender
{
    
//    [[SYNFacebookManager sharedFBManager] sendAppRequestToFriend:self.currentlySelectedFriend
//                                                       onSuccess:^{
//                                                           
//                                                           [appDelegate.viewStackManager removePopoverView];
//        
//                                                       } onFailure:^(NSError *error) {
//                                                           
//                                                           [appDelegate.viewStackManager removePopoverView];
//        
//                                                       }];
    
}

-(void)dealloc
{
    [self.searchContainer removeFromSuperview];
    // clean associations
    for (UICollectionViewCell* visibleCell in self.friendsCollectionView.visibleCells) {
        objc_removeAssociatedObjects(visibleCell);
    }
}

#pragma mark - iPhone Search bar

-(void)addSearchBarToView:(UIView*)view
{
    CGRect searchContainerFrame = self.searchContainer.frame;
    searchContainerFrame.origin = CGPointMake(46.0f, 0.0f);
    self.searchContainer.frame = searchContainerFrame;
    [view addSubview:self.searchContainer];
}

- (IBAction)closeSearchBox:(id)sender {
    [self.searchField resignFirstResponder];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationCurveEaseOut animations:^{
        CGRect newFrame = self.searchSlider.frame;
        newFrame.origin.x = newFrame.size.width;
        self.searchSlider.frame = newFrame;
    } completion:nil];
}

- (IBAction)revealSearchBox:(id)sender {
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationCurveEaseIn animations:^{
        CGRect newFrame = self.searchSlider.frame;
        newFrame.origin.x = 0.0f;
        self.searchSlider.frame = newFrame;
    } completion:^(BOOL finished) {
        [self.searchField becomeFirstResponder];
    }];
}

#pragma mark - Helper Methods

-(NSArray*)facebookFriends
{
    return [self.friends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"externalSystem == %@", kFacebook]];
}

-(NSArray*)rockpackFriends
{
    
    return [self.friends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"resourceURL != NULL"]];
}

@end
