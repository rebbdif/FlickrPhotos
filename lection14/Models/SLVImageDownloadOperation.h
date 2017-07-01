//
//  ImageDownloadOperation.h
//  lection14
//
//  Created by 1 on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SLVItem;
@class NSURLSession;

typedef NS_ENUM(NSInteger, SLVImageStatus) {
    SLVImageStatusDownloading,
    SLVImageStatusDownloaded,
    SLVImageStatusFiltered,
    SLVImageStatusCropped,
    SLVImageStatusCancelled,
    SLVImageStatusNone
};

@interface SLVImageDownloadOperation : NSOperation

@property (assign, nonatomic) SLVImageStatus status;

- (instancetype)initWithNetworkSession:(NSURLSession *)session item:(SLVItem *)item indexPath:(NSIndexPath *)indexPath cache:(NSCache *)cache;

- (void)pause;
- (void)resume;

@end