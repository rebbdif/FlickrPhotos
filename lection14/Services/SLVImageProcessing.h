//
//  SLVImageProcessing.h
//  lection14
//
//  Created by 1 on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface SLVImageProcessing : NSObject

+ (UIImage *)applyFilterToImage:(UIImage *)origin;
+ (UIImage *)cropImage:(UIImage *)origin width:(float)resultWidth heigth:(float)resultHeigth;

@end
