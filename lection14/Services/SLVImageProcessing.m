//
//  SLVImageProcessing.m
//  lection14
//
//  Created by 1 on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "SLVImageProcessing.h"

@implementation SLVImageProcessing

+ (UIImage *)applyFilterToImage:(UIImage *)origin {
    CIImage *originCI = [[CIImage alloc]initWithImage:origin];
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
    [filter setValue:originCI forKey:kCIInputImageKey];
    CIImage *resultCI = filter.outputImage;
    UIImage *result = [UIImage imageWithCIImage:resultCI];
    
    return result;
}

+ (UIImage *)cropImage:(UIImage *)origin toSize:(CGSize)itemSize {
    UIGraphicsBeginImageContextWithOptions(itemSize, YES, 0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [origin drawInRect:imageRect];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end
