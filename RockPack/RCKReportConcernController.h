//
//  SYNReportConcernController.h
//  rockpack
//
//  Created by Mats Trovik on 19/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCKReportConcernController : NSObject

/**
	initialiser setting the hostViewController which will display the report concern UI
	
    @param hostViewController view controller which will diplay the report concern UI
	@returns an initialised controller or nil;
 */
-(id)initWithHostViewController:(UIViewController*)hostViewController;


/**
	show the report concern UI
	@param presentingButton UI button to show the popup from on iPad. Will get deselected on on completion or cancellation.
	@param objectType the name of the type of object to report
	@param objectId the id of the object to report
 */
-(void)reportConcernFromView:(UIButton*)presentingButton objectType:(NSString*)objectType objectId:(NSString*)objectId;


@end
