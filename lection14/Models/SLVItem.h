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

@property (strong, nonatomic) NSURL *photoURL;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL applyFilterSwitherValue;
@property (assign, nonatomic) float downloadProgress;

+ (SLVItem * )itemWithDictionary:(NSDictionary *)dict;

@end
