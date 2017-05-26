//
//  NetworkManager.m
//  lection14
//
//  Created by iOS-School-1 on 04.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "SLVNetworkManager.h"

@interface SLVNetworkManager() <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@end

@implementation SLVNetworkManager

- (instancetype)init {
    self = [super init];
    if (self) {
        NSOperationQueue *downloadQueue = [NSOperationQueue new];
        downloadQueue.name = @"downloadQueue";
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:downloadQueue];
    }
    return self;
}

- (void)getModelFromURL:(NSURL *)url withCompletionHandler:(void (^)(NSData * data))completionHandler {
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completionHandler(data);
        if (error) {
            NSLog(@"error while downloading data %@",error.userInfo);
        }
    }];
    task.priority=NSURLSessionTaskPriorityHigh;
    [task resume];
}

- (NSURLSessionDownloadTask *)downloadImageFromURL:(NSURL *)url withCompletionHandler:(void (^)(NSData *data))completionHandler {
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSData *data = [NSData dataWithContentsOfURL:location];
        NSError *fileError = nil;
        [[NSFileManager defaultManager] removeItemAtURL:location error:&fileError];
        completionHandler(data);
    }];
    [task resume];
    return task;
}


@end
