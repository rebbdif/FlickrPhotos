//
//  SLVCache.h
//  lection14
//
//  Created by 1 on 01.07.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLVCache : NSObject

+ (instancetype)cacheWithCapacity:(NSUInteger)maxNumberOfItems;

- (instancetype)initWithCapacity:(NSUInteger)maxNumberOfItems;

- (NSUInteger)numberOfItems;

- (id)objectForKey:(id<NSCopying>)key;

- (void)setObject:(id)object forKey:(id<NSCopying>)key;

- (void)removeObjectForKey:(id<NSCopying>)key;

- (void)clear;

@end
