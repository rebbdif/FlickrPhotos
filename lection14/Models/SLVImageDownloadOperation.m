//
//  ImageDownloadOperation.m
//  lection14
//
//  Created by 1 on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "SLVImageDownloadOperation.h"
#import "SLVItem.h"
#import "SLVSearchResultsModel.h"
#import "SLVNetworkManager.h"
#import "SLVImageProcessing.h"
#import "SLVCache.h"

static const float kItemWidth = 312;
static const float kItemHeight = 312;

@interface SLVImageDownloadOperation()

@property (nonatomic, weak) NSURLSessionTask *task;
@property (nonatomic, weak) NSURLSession *session;
@property (nonatomic, weak) SLVItem *item;
@property (nonatomic, weak) NSIndexPath *indexPath;
@property (nonatomic, weak) SLVCache *imageCache;

@property (nonatomic, strong) dispatch_semaphore_t imageDownloadedSemaphore;

@end

@implementation SLVImageDownloadOperation

- (instancetype)initWithNetworkSession:(NSURLSession *)session item:(SLVItem *)item indexPath:(NSIndexPath *)indexPath cache:(SLVCache *)cache {
    self = [super init];
    if (self) {
        _session = session;
        _item = item;
        _indexPath = indexPath;
        _imageCache = cache;
        self.name = [NSString stringWithFormat:@"imageDownloadOperation for index %lu",indexPath.row];
    }
    return self;
}

- (void)main {
    self.imageDownloadedSemaphore = dispatch_semaphore_create(0);
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, nil);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.02 * NSEC_PER_SEC, 0.02 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [self fireTimer];
    });
    dispatch_resume(timer);
    
    [self loadImage];
    
    dispatch_semaphore_wait(self.imageDownloadedSemaphore, DISPATCH_TIME_FOREVER);
    dispatch_cancel(timer);
}

- (void)loadImage {
    __weak typeof(self) weakself = self;
    self.task = [SLVNetworkManager downloadImageWithSession:self.session fromURL:self.item.photoURL withCompletionHandler:^(NSData *data) {
        UIImage *downloadedImage = [UIImage imageWithData:data];
        UIImage *croppedImage = [SLVImageProcessing cropImage:downloadedImage width:kItemWidth heigth:kItemHeight];
        [weakself.imageCache setObject:croppedImage forKey:weakself.indexPath];
        dispatch_semaphore_signal(weakself.imageDownloadedSemaphore);
    }];
}

- (void)fireTimer {
    float received = self.task.countOfBytesReceived;
    float expected = self.task.countOfBytesExpectedToReceive;
    if (expected != 0) {
        self.item.downloadProgress = received / expected;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProgressNotification"
                                                                object:self.indexPath];
        });
    }
}

- (void)resume {
    [self.task resume];
    NSLog(@"operation %@ resumed", self.name);
}

- (void)pause {
    [self.task suspend];
    NSLog(@"operation %@ paused", self.name);
}

- (void)dealloc {
    NSLog(@"operation %@ dealloc", self.name);
}

@end
