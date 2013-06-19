//
//  SampleSpec.m
//  rockpack
//
//  Created by Nick Banks on 19/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Kiwi.h"

SPEC_BEGIN(RockpackMathSpec)

describe(@"Maths", ^{
    it(@"Eight Plus Two", ^{
        NSUInteger a = 8;
        NSUInteger b = 2;
        [[theValue(a + b) should] equal: theValue(10)];
    });
});

describe(@"Maths", ^{
    it(@"Two Plus Eight", ^{
        NSUInteger a = 2;
        NSUInteger b = 8;
        [[theValue(a + b) should] equal: theValue(10)];
    });
});

SPEC_END