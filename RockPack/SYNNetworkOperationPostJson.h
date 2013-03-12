//
//  SYNNetworkOperationPostJson.h
//  rockpack
//
//  Created by Michael Michailidis on 12/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "MKNetworkOperation.h"

@interface SYNNetworkOperationPostJson : MKNetworkOperation

@property (nonatomic, strong) id jsonObjectToPost;

@end
