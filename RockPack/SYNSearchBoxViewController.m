//
//  SYNAutocompleteViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 15/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNSearchBoxViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNAutocompleteSuggestionsController.h"
#import "SYNAppDelegate.h"
#import "AppConstants.h"
#import "SYNNetworkEngine.h"
#import "SYNDeviceManager.h"
#import "SYNTextField.h"
#import "MKNetworkOperation.h"

#define kGrayPanelBorderWidth 2.0

#define kAutocompleteTime 0.2

@interface SYNSearchBoxViewController ()

@property (nonatomic) CGFloat initialPanelHeight;
@property (nonatomic, strong) NSTimer* autocompleteTimer;
@property (nonatomic, strong) SYNAutocompleteSuggestionsController* autoSuggestionController;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@property (nonatomic, weak) SYNTextField* searchTextField;
@property (nonatomic, weak) MKNetworkOperation* autocompleteNetworkOperation;

@end


@implementation SYNSearchBoxViewController

@synthesize appDelegate;
@synthesize initialPanelHeight;
@synthesize searchBoxView;

- (void) loadView
{
    if ([SYNDeviceManager.sharedInstance isIPad])
    {
        self.view = [SYNSearchBoxView searchBoxView];
    }
    else
    {
        self.view = [[NSBundle mainBundle] loadNibNamed:@"SYNSearchBoxIphoneView" owner:self options:nil][0];
    }    
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.searchTextField = self.searchBoxView.searchTextField;
    self.searchTextField.delegate = self;
    [self.searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	
    self.autoSuggestionController = [[SYNAutocompleteSuggestionsController alloc] init];
    self.autoSuggestionController.tableView.delegate = self;
    
    CGRect tableViewFrame = self.autoSuggestionController.tableView.frame;
    
    if ([SYNDeviceManager.sharedInstance isIPad])
    {
        tableViewFrame.origin.x = self.searchTextField.frame.origin.x - 10.0;
        tableViewFrame.origin.y = 66.0;
    }
    else
    {
        tableViewFrame.origin.y = self.searchBoxView.frame.size.height;
    }
    
    self.autoSuggestionController.tableView.frame = tableViewFrame;
    self.autoSuggestionController.tableView.alpha = 0.0;
    [self.view addSubview:self.autoSuggestionController.tableView];
}




#pragma mark - Text Field Delegate

- (void) clear
{
    [self.autoSuggestionController clearWords];
    [self resizeTableView:YES];
}


- (void) textFieldDidChange: (UITextField *) textView
{
    if([textView.text length] == 0)
    {
        [self clear];
    }
}


- (void) textViewDidBeginEditing: (UITextView *) textView
{
    [textView setText: @""];
}


- (BOOL) textField: (UITextField *) textField
         shouldChangeCharactersInRange: (NSRange) range
         replacementString: (NSString *) newCharacter
{
    // 1. Do not accept blank characters at the beggining of the field
    
    if ([newCharacter isEqualToString: @" "] && self.searchTextField.text.length == 0)
        return NO;
    

    if((range.location - range.length) < 2)
        return YES;

    // == Restart Timer == //
    if (self.autocompleteTimer)
        [self.autocompleteTimer invalidate];
    
    self.autocompleteTimer = [NSTimer scheduledTimerWithTimeInterval: kAutocompleteTime
                                                              target: self
                                                            selector: @selector(performAutocompleteSearch:)
                                                            userInfo: nil
                                                             repeats: NO];
    return YES;
}


- (void) performAutocompleteSearch: (NSTimeInterval*) interval
{
    [self.autocompleteTimer invalidate];
    
    self.autocompleteTimer = nil;
    
    self.autocompleteNetworkOperation = [appDelegate.networkEngine getAutocompleteForHint: self.searchTextField.text
                                                                              forResource: EntityTypeVideo
                                                                             withComplete: ^(NSArray* array) {
                                             
                                             NSArray* suggestionsReturned = array[1];
                                             
                                             NSMutableArray* wordsReturned = [NSMutableArray array];
                                             
                                             if (suggestionsReturned.count == 0)
                                             {
                                                 [self.autoSuggestionController clearWords];
                                                 return;
                                             }
                                             
                                             for (NSArray* suggestion in suggestionsReturned)
                                             {
                                                 [wordsReturned addObject: suggestion[0]];
                                             }
                                             
                                             [self.autoSuggestionController addWords:wordsReturned];
                                             
                                             [self resizeTableView:NO];
                                             
                                             self.autoSuggestionController.tableView.alpha = 1.0;
                                             
                                         } andError: ^(NSError* error) {
                                         }];
}


- (void) resizeTableView:(BOOL)force
{
    if(force || [self.searchTextField isFirstResponder])
    {
        CGFloat tableViewHeight = self.autoSuggestionController.tableHeight;
        [self.searchBoxView resizeForHeight: tableViewHeight];
    }
}


- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    NSString* currentSearchTerm = self.searchTextField.text;
    
    if ([self.searchTextField.text isEqualToString: @""])
        return NO;
    
    [self.autocompleteTimer invalidate];    
    self.autocompleteTimer = nil;
    
    if(self.autocompleteNetworkOperation)
    {
        [self.autocompleteNetworkOperation cancel];
    }
    
    [self clear];
    
    // calls the MasterViewController
    
    [NSNotificationCenter.defaultCenter postNotificationName: kSearchTyped
                                                      object: self
                                                    userInfo :@{kSearchTerm : currentSearchTerm}];
    
    [self.searchTextField resignFirstResponder];
    
    return YES;
}

#pragma mark - TableView Delegate

- (void) tableView: (UITableView *) tableView
         didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSString* wordsSelected = [self.autoSuggestionController getWordAtIndex: indexPath.row];
    
    self.searchTextField.text = [wordsSelected uppercaseString];
    
    [self.autoSuggestionController clearWords];
    
    [self resizeTableView:YES];
    
    [self textFieldShouldReturn: self.searchTextField];
}


- (SYNSearchBoxView*) searchBoxView
{
    return (SYNSearchBoxView*)self.view;
}


@end
