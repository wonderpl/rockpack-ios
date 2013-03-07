//
//  SYNAutocompleteViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 05/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNAutocompleteViewController : UITableViewController {
    NSMutableArray* wordsArray;
    UIFont* rockpackFont;
    UIColor* textColor;
    UIColor* tableBGColor;
    
    
}

-(void)addWords:(NSArray*)words;
-(void)clearWords;

-(NSString*)getWordAtIndex:(NSInteger)index;

@end
