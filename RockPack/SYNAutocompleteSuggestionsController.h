//
//  SYNAutocompleteViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 05/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNAutocompleteSuggestionsController : UITableViewController {
    NSMutableArray* wordsArray;
    UIFont* rockpackFont;
    UIColor* textColor;
    UIColor* tableBGColor;
    
    
}

-(void)addWords:(NSArray*)words;
-(void)clearWords;

-(CGFloat)tableHeight;


-(NSString*)getWordAtIndex:(NSInteger)index;

@end
