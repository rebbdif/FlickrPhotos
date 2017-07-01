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

static const float kItemWidth = 312;
static const float kItemHeight = 312;

@interface SLVImageDownloadOperation()

@property (strong, nonatomic) NSURLSessionTask *task;
@property (strong, nonatomic) __block UIImage *downloadedImage;

@property (weak,nonatomic) NSURLSession *session;
@property (weak, nonatomic) SLVItem *item;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) NSCache *imageCache;

@end

@implementation SLVImageDownloadOperation

- (instancetype)initWithNetworkSession:(NSURLSession *)session item:(SLVItem *)item indexPath:(NSIndexPath *)indexPath cache:(NSCache *)cache {
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
    dispatch_semaphore_t imageDownloadedSemaphore = dispatch_semaphore_create(0);
    
    __weak typeof(self) weakself = self;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, nil);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.02 * NSEC_PER_SEC, 0.02 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        float received = weakself.task.countOfBytesReceived;
        float expected = weakself.task.countOfBytesExpectedToReceive;
        if (expected!=0) {
            weakself.item.downloadProgress = received / expected;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProgressNotification" object:self.indexPath];
            });
        }
    });
    
    dispatch_resume(timer);
    self.task = [SLVNetworkManager downloadImageWithSession:self.session fromURL:self.item.photoURL withCompletionHandler:^(NSData *data) {
        UIImage *downloadedImage = [UIImage imageWithData:data];
        weakself.downloadedImage = [SLVImageProcessing cropImage:downloadedImage width:kItemWidth heigth:kItemHeight];
        dispatch_semaphore_signal(imageDownloadedSemaphore);
    }];
    
    dispatch_semaphore_wait(imageDownloadedSemaphore, DISPATCH_TIME_FOREVER);
    dispatch_cancel(timer);
    
    if (self.downloadedImage) {
        [self.imageCache setObject:self.downloadedImage forKey:self.indexPath];
    } else {
        NSLog(@"ERROR - there was no Image downloaded");
    }
}

- (void)resume {
    [self.task resume];
    NSLog(@"operation %@ resumed", self.name);
}

- (void)pause {
    [self.task suspend];
    [self cancel];
    NSLog(@"operation %@ paused", self.name);
}

@end
