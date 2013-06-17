//
//  SYNAutocompleteViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 05/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAutocompleteIphoneCell.h"
#import "SYNAutocompleteSuggestionsController.h"
#import "SYNDeviceManager.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"

#define kDataCutOffPoint 8

@interface SYNAutocompleteSuggestionsController ()

@end


@implementation SYNAutocompleteSuggestionsController

- (id) initWithStyle: (UITableViewStyle) style
{
    
    if ((self = [super initWithStyle:style]))
    {
        wordsArray = [[NSMutableArray alloc] init];
        rockpackFont = [[SYNDeviceManager sharedInstance]isIPad] ?[UIFont rockpackFontOfSize: 26.0] : [UIFont rockpackFontOfSize: 18.0];
        
        textColor = [UIColor colorWithRed: (187.0f/255.0f)
                                    green: (187.0f/255.0f)
                                     blue: (187.0f/255.0f)
                                    alpha: (1.0f)];
        
        tableBGColor = [UIColor rockpacLedColor];
        
        self.title = @"Suggestions";
    }
    
    return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor rockpacLedColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.scrollEnabled = NO;
}


#pragma mark - Add Words

- (void) clearWords
{
    [wordsArray removeAllObjects];
    [self.tableView reloadData];
}


- (void) addWords: (NSArray*) words
{
    [wordsArray removeAllObjects];
    [wordsArray addObjectsFromArray: words];
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (CGFloat) tableHeight
{
    [self.tableView layoutIfNeeded];
    return [self.tableView contentSize].height;
}


- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return (wordsArray.count < kDataCutOffPoint) ? wordsArray.count : kDataCutOffPoint;
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    
    if (!cell)
    {
        if ([SYNDeviceManager.sharedInstance isIPad])
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            cell.contentView.backgroundColor = [UIColor clearColor];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.backgroundColor = [UIColor clearColor];
            
            // Text
            cell.textLabel.font = rockpackFont;
            cell.textLabel.textColor = textColor;
        }
        else
        {
            cell = [[SYNAutocompleteIphoneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        } 
    }

    cell.textLabel.text = [((NSString*)wordsArray[indexPath.row]) uppercaseString];

    return cell;
}


- (NSString*) getWordAtIndex: (NSInteger) index
{
    return (NSString*)wordsArray[index];
}


@end
