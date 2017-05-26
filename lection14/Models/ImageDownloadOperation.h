//
//  ImageDownloadOperation.h
//  lection14
//
//  Created by 1 on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@class SLVItem;
@class SLVNetworkManager;

typedef NS_ENUM(NSInteger, SLVImageStatus) {
    SLVImageStatusDownloading,
    SLVImageStatusDownloaded,
    SLVImageStatusFiltered,
    SLVImageStatusCropped,
    SLVImageStatusCancelled,
    SLVImageStatusNone
};

@interface ImageDownloadOperation : NSOperation

@property (weak, nonatomic) SLVItem *item;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (assign, nonatomic) SLVImageStatus status;
@property (weak, nonatomic) SLVNetworkManager *networkManager;
@property (assign, nonatomic) CGSize imageViewSize;
@property (weak, nonatomic) NSCache *imageCache;

- (void)pause;
- (void)resume;

@end
