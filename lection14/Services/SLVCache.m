//
//  SLVCache.m
//  lection14
//
//  Created by 1 on 01.07.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "SLVCache.h"

@interface SLVCache()

@property (nonatomic, strong) NSMutableDictionary *cashe;
@property (nonatomic, assign, readonly) NSUInteger capacity;
@property (nonatomic, strong) NSMutableArray<id<NSCopying>> *keys;

@end

@implementation SLVCache

+ (instancetype)cacheWithCapacity:(NSUInteger)maxNumberOfItems {
    SLVCache *cache = [[SLVCache alloc] initWithCapacity:maxNumberOfItems];
    return cache;
}

- (instancetype)initWithCapacity:(NSUInteger)maxNumberOfItems {
    self = [super init];
    if (self) {
        _cashe = [NSMutableDictionary dictionaryWithCapacity:maxNumberOfItems];
        _capacity = maxNumberOfItems;
        _keys = [NSMutableArray arrayWithCapacity:maxNumberOfItems];
    }
    return self;
}

- (NSUInteger)numberOfItems {
    return self.cashe.count;
}

- (id)objectForKey:(id<NSCopying>)key {
    return self.cashe[key];
}

- (void)setObject:(id)object forKey:(id<NSCopying>)key {
    if (!object || !key) {
        return;
    }
    if (!self.cashe[key]) {
        if (self.cashe.count < self.capacity) {
            self.cashe[key] = object;
            [self.keys addObject:key];
        } else {
            id<NSCopying> removedKey = [self.keys firstObject];
            [self.keys removeObject:removedKey];
            [self.cashe removeObjectForKey:removedKey];
            [self.keys addObject:key];
            self.cashe[key] = object;
        }
    } else {
        [self.keys removeObject:key];
        self.cashe[key] = object;
        [self.keys addObject:key];
    }
}

- (void)removeObjectForKey:(id<NSCopying>)key {
    [self.cashe removeObjectForKey:key];
    [self.keys removeObject:key];
}

- (void)clear {
    [self.cashe removeAllObjects];
    [self.keys removeAllObjects];
}


@end
