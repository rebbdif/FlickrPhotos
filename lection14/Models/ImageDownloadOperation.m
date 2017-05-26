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
#import "SLVImageProcessing.h"


@interface ImageDownloadOperation()

@property (strong, nonatomic) NSOperationQueue *innerQueue;
@property (strong, nonatomic) NSURLSessionTask *task;
@property (strong, nonatomic) NSOperation *downloadOperation;
@property (strong, nonatomic) NSOperation *cropOperation;
@property (strong, nonatomic) NSOperation *applyFilterOperation;

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
    
    self.downloadOperation = [NSBlockOperation blockOperationWithBlock:^{
        __weak typeof(self) weakself = self;
        self.task = [self.networkManager downloadImageFromURL:self.item.photoURL withCompletionHandler:^(NSData *data) {
            downloadedImage = [UIImage imageWithData:data];
            weakself.status = SLVImageStatusDownloaded;
            dispatch_semaphore_signal(imageDownloadedSemaphore);
        }];
    }];
    
    self.cropOperation = [NSBlockOperation blockOperationWithBlock:^{
        downloadedImage = [SLVImageProcessing cropImage:downloadedImage toSize:self.imageViewSize];
    }];
    [self.cropOperation addDependency:self.downloadOperation];
    
    self.applyFilterOperation = [NSBlockOperation blockOperationWithBlock:^{
        downloadedImage = [SLVImageProcessing applyFilterToImage:downloadedImage];
    }];
    [self.applyFilterOperation addDependency:self.cropOperation];
        
    self.status = SLVImageStatusDownloading;
    [self.innerQueue addOperation:self.downloadOperation];
    dispatch_semaphore_wait(imageDownloadedSemaphore, DISPATCH_TIME_FOREVER);
    
    [self.innerQueue addOperations:@[self.cropOperation] waitUntilFinished:YES];
    self.status = SLVImageStatusCropped;
    
    if (downloadedImage) {
        [self.imageCache setObject:downloadedImage forKey:self.item.photoURL];
    } else {
        self.status = SLVImageStatusNone;
    }
    
    if (self.item.applyFilterSwitherValue == NO) {
        return;
    } else {
        [self applyFilter];
    }
    
    if (downloadedImage) {
        [self.imageCache setObject:downloadedImage forKey:self.item.photoURL];
    } else {
        self.status = SLVImageStatusNone;
    }
}

- (void)resume {
    self.innerQueue.suspended = NO;
    [self.task resume];
    NSLog(@"operation %ld resumed", (long)self.indexPath.row);
}

- (void)applyFilter {
    [self.innerQueue addOperations:@[self.applyFilterOperation] waitUntilFinished:YES];
    self.status = SLVImageStatusFiltered;
}

- (void)pause {
    NSLog(@"operation %ld paused", (long)self.indexPath.row);
    self.innerQueue.suspended = YES;
    self.status = SLVImageStatusCancelled;
    [self.task suspend];
    [self cancel];
}

@end
