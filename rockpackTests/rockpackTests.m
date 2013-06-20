//
//  rockpackTests.m
//  rockpackTests
//
//  Created by Nick Banks on 19/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "rockpackTests.h"

@implementation rockpackTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testTwoPlusTwo
{
    NSUInteger a = 2;
    NSUInteger b = 2;

    STAssertTrue((a + b) == 4, @"A + B = 4");
}


- (void)testFourPlusFour
{
    NSUInteger a = 4;
    NSUInteger b = 4;
    
    STAssertTrue((a + b) == 8, @"A + B = 8");
}

@end
