//
//  Item.h
//  lection14
//
//  Created by iOS-School-1 on 04.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@interface SLVItem : NSObject

@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL applyFilterSwitherValue;
@property (nonatomic, assign) float downloadProgress;

+ (SLVItem *)itemWithDictionary:(NSDictionary *)dict;

@end
