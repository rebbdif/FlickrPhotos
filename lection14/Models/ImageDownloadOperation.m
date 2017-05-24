//
//  ImageDownloadOperation.m
//  lection14
//
//  Created by 1 on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "ImageDownloadOperation.h"
#import "SLVItem.h"
#import "SLVSearchResultsModel.h"
#import "SLVNetworkManager.h"

@interface ImageDownloadOperation()

@property (assign,nonatomic,readwrite) SLVImageStatus status;
@property (strong,nonatomic) NSOperationQueue *innerQueue;

@end

@implementation ImageDownloadOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        _status = SLVImageStatusNone;
        _innerQueue = [NSOperationQueue new];
        _imageViewSize = CGSizeMake(312, 312);
    }
    return self;
}

- (void)main {
    __block UIImage *downloadedImage;
    dispatch_semaphore_t imageDownloadedSemaphore = dispatch_semaphore_create(0);
    NSOperation *downloadOperation = [NSBlockOperation blockOperationWithBlock:^{
        __weak typeof(self) weakself = self;
        [self.networkManager downloadImageFromURL:self.item.photoURL withCompletionHandler:^(NSData *data) {
            downloadedImage = [UIImage imageWithData:data];
            weakself.status = SLVImageStatusDownloaded;
            dispatch_semaphore_signal(imageDownloadedSemaphore);
        }];
    }];
    
    NSOperation *cropOperation = [NSBlockOperation blockOperationWithBlock:^{
        CGSize itemSize = self.imageViewSize;
        if (downloadedImage.size.width != itemSize.width  || downloadedImage.size.height != itemSize.height) {
            UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [downloadedImage drawInRect:imageRect];
            downloadedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        self.item.photo = downloadedImage;
    }];
    [cropOperation addDependency:downloadOperation];
    
    self.status = SLVImageStatusDownloading;
    [self.innerQueue addOperation:downloadOperation];
    dispatch_semaphore_wait(imageDownloadedSemaphore, DISPATCH_TIME_FOREVER);
    [self.innerQueue addOperation:cropOperation];
    [self.innerQueue waitUntilAllOperationsAreFinished];
}

@end
