//
//  SYNAutocompleteViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 05/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAutocompleteSuggestionsController.h"
#import "UIFont+SYNFont.h"
#import "UIColor+SYNColor.h"

@interface SYNAutocompleteSuggestionsController ()

@end

@implementation SYNAutocompleteSuggestionsController

- (id)initWithStyle:(UITableViewStyle)style
{
    
    self = [super initWithStyle:style];
    
    if (self) {
        
        wordsArray = [[NSMutableArray alloc] init];
        rockpackFont = [UIFont rockpackFontOfSize:26.0];
        textColor = [UIColor colorWithRed:(187.0f/255.0f) green:(187.0f/255.0f) blue:(187.0f/255.0f) alpha:(1.0f)];
        tableBGColor = [UIColor rockpacLedColor];
        
        self.title = @"Suggestions";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor rockpacLedColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Add Words
-(void)clearWords
{
    [wordsArray removeAllObjects];
    [self.tableView reloadData];
}

-(void)addWords:(NSArray*)words
{
    [wordsArray removeAllObjects];
    [wordsArray addObjectsFromArray:words];
    [self.tableView reloadData];
}
#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return wordsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] init];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.backgroundColor = [UIColor clearColor];
        
        
        // Text
        
        cell.textLabel.font = rockpackFont;
        cell.textLabel.textColor = textColor;
        
        
    }
    
    
    cell.textLabel.text = [((NSString*)wordsArray[indexPath.row]) uppercaseString];
    
    // Configure the cell...
    
    return cell;
}



-(NSString*)getWordAtIndex:(NSInteger)index
{
    return (NSString*)[wordsArray objectAtIndex:index];
}


@end
