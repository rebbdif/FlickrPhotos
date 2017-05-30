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
@property (strong, nonatomic) __block UIImage *downloadedImage;

@end

@implementation ImageDownloadOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        _status = SLVImageStatusNone;
        _innerQueue = [NSOperationQueue new];
        _innerQueue.name = [NSString stringWithFormat:@"innerQueue for index %lu",self.indexPath.row];
        _imageViewSize = CGSizeMake(312, 312);
    }
    return self;
}

- (void)main {
    NSLog(@"operation %ld began", (long)self.indexPath.row);
    dispatch_semaphore_t imageDownloadedSemaphore = dispatch_semaphore_create(0);
    
    self.downloadOperation = [NSBlockOperation blockOperationWithBlock:^{
        __weak typeof(self) weakself = self;
        weakself.task = [SLVNetworkManager downloadImageWithSession:self.session fromURL:self.item.photoURL withCompletionHandler:^(NSData *data) {
            weakself.downloadedImage = [UIImage imageWithData:data];
            weakself.status = SLVImageStatusDownloaded;
            dispatch_semaphore_signal(imageDownloadedSemaphore);
        }];
    }];
    
    self.cropOperation = [NSBlockOperation blockOperationWithBlock:^{
        self.downloadedImage = [SLVImageProcessing cropImage:self.downloadedImage toSize:self.imageViewSize];
    }];
    [self.cropOperation addDependency:self.downloadOperation];
    
    self.applyFilterOperation = [NSBlockOperation blockOperationWithBlock:^{
        self.downloadedImage = [SLVImageProcessing applyFilterToImage:self.downloadedImage];
    }];
    [self.applyFilterOperation addDependency:self.cropOperation];
    
    self.status = SLVImageStatusDownloading;
    NSLog(@"operation %ld downloading", (long)self.indexPath.row);
    [self.innerQueue addOperation:self.downloadOperation];
    
    __weak typeof(self) weakself = self;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, nil);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        float received = weakself.task.countOfBytesReceived;
        float expected = weakself.task.countOfBytesExpectedToReceive;
        if (expected!=0) {
            weakself.item.downloadProgress = received/expected;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProgressNotification" object:self.indexPath];
        }
    });
    dispatch_resume(timer);
    
    dispatch_semaphore_wait(imageDownloadedSemaphore, DISPATCH_TIME_FOREVER);
    dispatch_cancel(timer);
    NSLog(@"operation %ld downloaded", (long)self.indexPath.row);
    
    [self.innerQueue addOperations:@[self.cropOperation] waitUntilFinished:YES];
    self.status = SLVImageStatusCropped;
    NSLog(@"operation %ld cropped", (long)self.indexPath.row);
    
    if (self.downloadedImage) {
        [self.imageCache setObject:self.downloadedImage forKey:self.indexPath];
    } else {
        self.status = SLVImageStatusNone;
    }
    NSLog(@"operation %ld finished", (long)self.indexPath.row);
}

- (void)resume {
    self.innerQueue.suspended = NO;
    [self.task resume];
    NSLog(@"operation %ld resumed", (long)self.indexPath.row);
}

- (void)pause {
    self.innerQueue.suspended = YES;
    self.status = SLVImageStatusCancelled;
    [self.task suspend];
    [self cancel];
    NSLog(@"operation %ld paused", (long)self.indexPath.row);
}

@end
