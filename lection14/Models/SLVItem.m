//
//  Item.m
//  lection14
//
//  Created by iOS-School-1 on 04.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "SLVItem.h"

@implementation SLVItem

+ (SLVItem *)itemWithDictionary:(NSDictionary *)dict {
    SLVItem *item = [SLVItem new];
    item.title = dict[@"title"];
    
    NSString *secret = dict[@"secret"];
    NSString *server = dict[@"server"];
    NSString *farm = dict[@"farm"];
    NSString *idd = dict[@"id"];
    
    NSString *url = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_h.jpg", farm, server, idd, secret];
    
    item.photoURL = [NSURL URLWithString:url];
    item.applyFilterSwitherValue = NO;
    return item;
}

@end
