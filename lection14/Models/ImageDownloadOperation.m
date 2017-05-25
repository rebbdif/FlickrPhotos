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
    NSLog(@"started operations for row: %ld", (long)self.indexPath.row);
    __block UIImage *downloadedImage;
    dispatch_semaphore_t imageDownloadedSemaphore = dispatch_semaphore_create(0);
    
    NSOperation *downloadOperation = [NSBlockOperation blockOperationWithBlock:^{
        __weak typeof(self) weakself = self;
        [self.networkManager downloadImageFromURL:self.item.photoURL withCompletionHandler:^(NSData *data) {
            downloadedImage = [UIImage imageWithData:data];
            weakself.status = SLVImageStatusDownloaded;
            NSLog(@"downloadedImage for row: %ld", (long)self.indexPath.row);
            dispatch_semaphore_signal(imageDownloadedSemaphore);
        }];
    }];
    
    NSOperation *cropOperation = [NSBlockOperation blockOperationWithBlock:^{
        downloadedImage = [SLVImageProcessing cropImage:downloadedImage toSize:self.imageViewSize];
    }];
    [cropOperation addDependency:downloadOperation];
    
    NSOperation *applyFilter = [NSBlockOperation blockOperationWithBlock:^{
        downloadedImage = [SLVImageProcessing applyFilterToImage:downloadedImage];
    }];
    [applyFilter addDependency:cropOperation];
    
    [self ifCancelled];
    
    self.status = SLVImageStatusDownloading;
    [self.innerQueue addOperation:downloadOperation];
    dispatch_semaphore_wait(imageDownloadedSemaphore, DISPATCH_TIME_FOREVER);
    
    [self.innerQueue addOperations:@[cropOperation] waitUntilFinished:YES];
    self.status = SLVImageStatusCropped;
    
    [self ifCancelled];
    
    [self.innerQueue addOperations:@[applyFilter] waitUntilFinished:YES];
    self.status = SLVImageStatusFiltered;
    if (downloadedImage) {
    [self.imageCache setObject:downloadedImage forKey:self.item.photoURL];
    } else {
        self.status = SLVImageStatusNone;
    }
    NSLog(@"completed work with image for row: %ld", (long)self.indexPath.row);
}

- (void)ifCancelled {
    if (self.cancelled) {
        self.innerQueue.suspended = YES;
        NSLog(@"operation %ld cancelled", (long)self.indexPath.row);
        return;
    }
}

- (void)resume {
    self.innerQueue.suspended = NO;
    NSLog(@"operation %ld resumed", (long)self.indexPath.row);
}

@end
