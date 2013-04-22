//
//  SYNAutocompleteViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 15/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchBoxViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNAutocompleteSuggestionsController.h"
#import "SYNAppDelegate.h"
#import "AppConstants.h"
#import "SYNNetworkEngine.h"
#import "SYNDeviceManager.h"

#define kGrayPanelBorderWidth 2.0

#define kAutocompleteTime 0.2

@interface SYNSearchBoxViewController ()

@property (nonatomic, strong) UITextField* searchTextField;
@property (nonatomic, strong) SYNAutocompleteSuggestionsController* autoSuggestionController;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@property (nonatomic) CGRect originalFrame;
@property (nonatomic, strong) UIView* backgroundPanel;
@property (nonatomic, strong) UIView* grayPanel;


@property (nonatomic, strong) NSTimer* autocompleteTimer;

@property (nonatomic) CGFloat initialPanelHeight;

@end

@implementation SYNSearchBoxViewController

@synthesize searchTextField;
@synthesize appDelegate;
@synthesize originalFrame;
@synthesize backgroundPanel;
@synthesize initialPanelHeight;
@synthesize grayPanel;
@synthesize isOnScreen;

-(void)loadView
{
    
    
    CGFloat barWidth = [[SYNDeviceManager sharedInstance] currentScreenWidth] - 90.0;
    
    self.backgroundPanel = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                                      barWidth, 61.0)];
    backgroundPanel.backgroundColor = [UIColor whiteColor];
    
    backgroundPanel.autoresizesSubviews = YES;
    
    initialPanelHeight = self.backgroundPanel.frame.size.height;
    
    // == Gray Panel == //
    
    self.grayPanel = [[UIView alloc] initWithFrame:CGRectMake(kGrayPanelBorderWidth,
                                                              kGrayPanelBorderWidth,
                                                              backgroundPanel.frame.size.width - kGrayPanelBorderWidth * 2,
                                                              backgroundPanel.frame.size.height - kGrayPanelBorderWidth * 2)];
    
    grayPanel.backgroundColor = [UIColor colorWithRed:(249.0/255.0) green:(249.0/255.0) blue:(249.0/255.0) alpha:(1.0)];
    grayPanel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [backgroundPanel addSubview:grayPanel];
    
    backgroundPanel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    
    
    // == Loop == //
    
    UIImage* loopImage = [UIImage imageNamed:@"IconSearch"];
    UIImageView* loopImageView = [[UIImageView alloc] initWithImage:loopImage];
    loopImageView.frame = CGRectMake(10.0, 14.0, loopImage.size.width, loopImage.size.height);
    loopImageView.image = loopImage;
    grayPanel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [grayPanel addSubview:loopImageView];
    
    
    // == Label == //
    
    CGRect fieldRect = grayPanel.frame;
    fieldRect.origin.x += 18.0 + loopImage.size.width;
    fieldRect.origin.y += 12.0;
    fieldRect.size.width -= 10.0 * 2;
    fieldRect.size.height -= 10.0 * 2;
    self.searchTextField = [[UITextField alloc] initWithFrame:fieldRect];
    self.searchTextField.font = [UIFont rockpackFontOfSize:26.0];
    self.searchTextField.backgroundColor = [UIColor clearColor];
    self.searchTextField.textAlignment = NSTextAlignmentLeft;
    self.searchTextField.delegate = self;
    self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    
    
    
    CGRect finalFrame = backgroundPanel.frame;
    
    
    self.view = [[UIView alloc] initWithFrame:finalFrame];
    [self.view addSubview:backgroundPanel];
    [self.view addSubview:self.searchTextField];
    
    self.view.autoresizesSubviews = YES;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
	
    self.autoSuggestionController = [[SYNAutocompleteSuggestionsController alloc] init];
    self.autoSuggestionController.tableView.delegate = self;
    
    CGRect tableViewFrame = self.autoSuggestionController.tableView.frame;
    tableViewFrame.origin.x = self.searchTextField.frame.origin.x - 10.0;
    tableViewFrame.origin.y = 66.0;
    self.autoSuggestionController.tableView.frame = tableViewFrame;
    self.autoSuggestionController.tableView.alpha = 0.0;
    [self.view addSubview:self.autoSuggestionController.tableView];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    isOnScreen = YES;
    
    
    [self.searchTextField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    isOnScreen = NO;
}

#pragma mark - Text Field Delegate

- (void) clear
{
    self.searchTextField.text = @"";
    
    [self.autoSuggestionController clearWords];
    
    [self resizeTableView];
    
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
    
    
    
    // == Restart Timer == //
    
    if(self.autocompleteTimer)
        [self.autocompleteTimer invalidate];
    
    
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
    originalFrame = self.view.frame;
    
    CGFloat tableViewHeight = self.autoSuggestionController.tableHeight;
    
    
    CGRect panelFrame = self.backgroundPanel.frame;
    panelFrame.size.height = initialPanelHeight + tableViewHeight + (tableViewHeight > 0.0 ? 10.0 : 0.0);
    backgroundPanel.frame = panelFrame;
    
    panelFrame.origin.x += kGrayPanelBorderWidth;
    panelFrame.origin.y += kGrayPanelBorderWidth;
    panelFrame.size.width -= kGrayPanelBorderWidth * 2;
    panelFrame.size.height -= kGrayPanelBorderWidth * 2;
    self.grayPanel.frame = panelFrame;
    
    
    CGRect selfFrame = self.view.frame;
    selfFrame.size.height = panelFrame.size.height;
    self.view.frame = selfFrame;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSString* currentSearchTerm = self.searchTextField.text;
    
    if ([self.searchTextField.text isEqualToString:@""])
        return NO;
    
    [self.autocompleteTimer invalidate];    
    self.autocompleteTimer = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSearchTyped object:self userInfo:@{kSearchTerm:currentSearchTerm}];
    
    
    [textField resignFirstResponder];
    
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
}


#pragma mark - TableView Delegate

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSString* wordsSelected = [self.autoSuggestionController getWordAtIndex: indexPath.row];
    self.searchTextField.text = [wordsSelected uppercaseString];
    
    [self.autoSuggestionController clearWords];
    
    [self resizeTableView];
    
    
    
    [self textFieldShouldReturn: self.searchTextField];
    
}



@end