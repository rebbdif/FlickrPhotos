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
@class SLVCache;

@interface SLVImageDownloadOperation : NSOperation

@property (nonatomic, weak, readonly) NSIndexPath *indexPath;

- (instancetype)initWithNetworkSession:(NSURLSession *)session item:(SLVItem *)item indexPath:(NSIndexPath *)indexPath cache:(SLVCache *)cache;

- (void)pause;

- (void)resume;

@end
