//
//  SLVImageProcessing.m
//  lection14
//
//  Created by 1 on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "SLVImageProcessing.h"
@import UIKit;

@implementation SLVImageProcessing

+ (UIImage *)applyFilterToImage:(UIImage *)origin {
    CIImage *originCI = [[CIImage alloc]initWithImage:origin];
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
    [filter setValue:originCI forKey:kCIInputImageKey];
    CIImage *resultCI = filter.outputImage;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGRect extent = [resultCI extent];
    CGImageRef cgImage = [context createCGImage:resultCI fromRect:extent];
    
    UIImage *filteredImage = [[UIImage alloc] initWithCGImage:cgImage];
    
    return filteredImage;
}

+ (UIImage *)cropImage:(UIImage *)origin width:(float)resultWidth heigth:(float)resultHeigth {
    CGSize itemSize = CGSizeMake(resultWidth, resultHeigth);
    
    CGFloat side;
    CGFloat width = origin.size.width;
    CGFloat heigth = origin.size.height;
    UIImage *squareImage;
    
    if (heigth > width) {
        side = width;
        CGFloat offset = (heigth - width) / 2;
        CGRect croppedRect = CGRectMake(0, offset, side, side);
        CGImageRef img = CGImageCreateWithImageInRect(origin.CGImage, croppedRect);
        squareImage = [[UIImage alloc] initWithCGImage:img];
        img = nil;
    } else {
        side = heigth;
        CGFloat offset = (width - heigth) / 2;
        CGRect croppedRect = CGRectMake(offset, 0, side, side);
        CGImageRef img = CGImageCreateWithImageInRect(origin.CGImage, croppedRect);
        squareImage = [[UIImage alloc] initWithCGImage:img];
        img = nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(itemSize, YES, 0.0);
    CGRect imageRect2 = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [squareImage drawInRect:imageRect2];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end
