//
//  SLVTestCache.m
//  lection14
//
//  Created by 1 on 01.07.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SLVCache.h"

@interface SLVTestCache : XCTestCase

@end

@implementation SLVTestCache

- (void)testAddingNewObjectNormal {
    SLVCache *cache = [SLVCache cacheWithCapacity:10];
    [cache setObject:@"object1" forKey:@"key1"];
    [cache setObject:@"object2" forKey:@"key2"];
    
    XCTAssertEqual([cache numberOfItems], 2);
    
    NSString *object = ((NSString *)([cache objectForKey:@"key1"]));
    XCTAssert([object isEqualToString:@"object1"]);
}

- (void)testAddingNewObjectOverflow {
    SLVCache *cache = [SLVCache cacheWithCapacity:3];
    [cache setObject:@"object1" forKey:@"key1"];
    [cache setObject:@"object2" forKey:@"key2"];
    [cache setObject:@"object3" forKey:@"key3"];
    [cache setObject:@"object4" forKey:@"key4"];
    [cache setObject:@"object5" forKey:@"key5"];

    XCTAssertEqual([cache numberOfItems], 3);
    
    XCTAssertNil([cache objectForKey:@"key1"]);
    XCTAssertNil([cache objectForKey:@"key2"]);
    
    NSString *object3 = ((NSString *)([cache objectForKey:@"key3"]));
    XCTAssert([object3 isEqualToString:@"object3"]);
    NSString *object4 = ((NSString *)([cache objectForKey:@"key4"]));
    XCTAssert([object4 isEqualToString:@"object4"]);
}

- (void)testAddingObjectForExistingKey {
    SLVCache *cache = [SLVCache cacheWithCapacity:10];
    [cache setObject:@"object1" forKey:@"key1"];
    [cache setObject:@"object2" forKey:@"key2"];
    [cache setObject:@"object3" forKey:@"key3"];
    [cache setObject:@"object4" forKey:@"key4"];
    [cache setObject:@"object5" forKey:@"key5"];

    [cache setObject:@"newObject" forKey:@"key3"];
    
    NSString *object = ((NSString *)([cache objectForKey:@"key3"]));
    XCTAssert([object isEqualToString:@"newObject"]);
    
    XCTAssertEqual([cache numberOfItems], 5);
}

- (void)testNil {
    SLVCache *cache = [SLVCache cacheWithCapacity:3];
    [cache setObject:@"object1" forKey:@"key1"];
    [cache setObject:@"object2" forKey:@"key2"];
    [cache setObject:@"object3" forKey:@"key3"];
    
    [cache setObject:@"object" forKey:nil];
    [cache setObject:nil forKey:@"key"];

    id object = [cache objectForKey:nil];
    XCTAssertNoThrow(@"nothrow");
    XCTAssertNil(object);
}


@end
