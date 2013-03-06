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
}


-(void)addWord:(NSString*)word;
-(void)addWords:(NSArray*)words;

-(NSString*)getWordAtIndex:(NSInteger)index;

@end
