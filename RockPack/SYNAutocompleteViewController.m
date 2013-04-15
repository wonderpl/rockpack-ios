//
//  SYNAutocompleteViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 15/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAutocompleteViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNAutocompleteSuggestionsController.h"
#import "SYNAppDelegate.h"
#import "AppConstants.h"
#import "SYNNetworkEngine.h"

#define kGrayPanelBorderWidth 2.0

#define kAutocompleteTime 0.2

@interface SYNAutocompleteViewController ()

@property (nonatomic, strong) UITextField* searchTextField;
@property (nonatomic, strong) SYNAutocompleteSuggestionsController* autoSuggestionController;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;


@property (nonatomic, strong) NSTimer* autocompleteTimer;

@end

@implementation SYNAutocompleteViewController

@synthesize searchTextField;
@synthesize appDelegate;


-(void)loadView
{
    UIView* autocompletePanel = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 700.0, 50.0)];
    autocompletePanel.backgroundColor = [UIColor whiteColor];
    
    // == Gray Panel == //
    
    UIView* grayPanel = [[UIView alloc] initWithFrame:CGRectMake(kGrayPanelBorderWidth,
                                                                kGrayPanelBorderWidth,
                                                                autocompletePanel.frame.size.width - kGrayPanelBorderWidth * 2,
                                                                autocompletePanel.frame.size.height - kGrayPanelBorderWidth * 2)];
    
    grayPanel.backgroundColor = [UIColor lightGrayColor];
    [autocompletePanel addSubview:grayPanel];
    
    
    
    // == Label == //
    
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 10.0, 500.0, 40.0)];
    self.searchTextField.font = [UIFont rockpackFontOfSize:18.0];
    self.searchTextField.backgroundColor = [UIColor clearColor];
    self.searchTextField.textAlignment = NSTextAlignmentLeft;
    self.searchTextField.delegate = self;
    [autocompletePanel addSubview:self.searchTextField];
    
    self.view = autocompletePanel;
    self.view.autoresizesSubviews = YES;
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
	
    self.autoSuggestionController = [[SYNAutocompleteSuggestionsController alloc] init];
    self.autoSuggestionController.tableView.delegate = self;
    
    CGRect tableViewFrame = self.autoSuggestionController.tableView.frame;
    tableViewFrame.origin.y = 50.0;
    self.autoSuggestionController.tableView.frame = tableViewFrame;
    self.autoSuggestionController.tableView.alpha = 0.0;
    [self.view addSubview:self.autoSuggestionController.tableView];
    
}


#pragma mark - Text Field Delegate

- (void) clearSearchField: (id) sender
{
    self.searchTextField.text = @"";
    
    //self.clearTextButton.alpha = 0.0;
    
    [self.searchTextField resignFirstResponder];
}


- (void) textViewDidChange: (UITextView *) textView
{
    
}



- (void) textViewDidBeginEditing: (UITextView *) textView
{
    [textView setText: @""];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)newCharacter
{
    // 1. Do not accept blank characters at the beggining of the field
    
    if([newCharacter isEqualToString:@" "] && self.searchTextField.text.length == 0)
        return NO;
    
    
    //    if(self.searchTextField.text.length < 1)
    //        return YES;
    
    if(self.autocompleteTimer) {
        [self.autocompleteTimer invalidate];
    }
    
    self.autocompleteTimer = [NSTimer scheduledTimerWithTimeInterval:kAutocompleteTime
                                                              target:self
                                                            selector:@selector(performAutocompleteSearch:)
                                                            userInfo:nil
                                                             repeats:NO];
    return YES;
}

-(void)performAutocompleteSearch:(NSTimeInterval*)interval
{
    
    if(self.searchTextField.text.length == 0) {
        [UIView animateWithDuration:0.5 animations:^{
            //self.clearTextButton.alpha = 0.0;
        }];
        
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            //self.clearTextButton.alpha = 1.0;
        }];
    }
    
    
    [self.autocompleteTimer invalidate];
    
    self.autocompleteTimer = nil;
    
    
    [appDelegate.networkEngine getAutocompleteForHint:self.searchTextField.text
                                          forResource:EntityTypeVideo
                                         withComplete:^(NSArray* array) {
                                             
                                             NSArray* suggestionsReturned = [array objectAtIndex:1];
                                             
                                             NSMutableArray* wordsReturned = [NSMutableArray array];
                                             
                                             if(suggestionsReturned.count == 0) {
                                                 
                                                 [self.autoSuggestionController clearWords];
                                                 
                                                 
                                                 
                                                 return;
                                             }
                                             
                                             for (NSArray* suggestion in suggestionsReturned)
                                                 [wordsReturned addObject:[suggestion objectAtIndex:0]];
                                             
                                             [self.autoSuggestionController addWords:wordsReturned];
                                             
                                             [self resizeTableView];
                                             
                                             self.autoSuggestionController.tableView.alpha = 1.0;
                                             
                                         } andError:^(NSError* error) {
                                             
                                             
                                             
                                         }];
    
    
}

-(void)resizeTableView
{
    CGRect tableViewFrame = self.autoSuggestionController.tableView.frame;
    tableViewFrame.size.height = 200.0;
    self.autoSuggestionController.tableView.frame = tableViewFrame;
    CGRect selfFrame = self.view.frame;
    selfFrame.size.height = selfFrame.size.height + tableViewFrame.size.height;
    self.view.frame = selfFrame;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    if ([self.searchTextField.text isEqualToString:@""])
        return NO;
    
    [self.autocompleteTimer invalidate];
    self.autocompleteTimer = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSearchTyped object:self];
    
    
    [textField resignFirstResponder];
    
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
}


#pragma mark - TableView Delegate

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSString* wordsSelected = [self.autoSuggestionController getWordAtIndex: indexPath.row];
    self.searchTextField.text = wordsSelected;
    
    [self textFieldShouldReturn: self.searchTextField];
}



@end
