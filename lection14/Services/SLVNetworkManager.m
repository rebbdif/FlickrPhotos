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

- (NSURLSessionDataTask *)downloadImageFromURL:(NSURL *)url withCompletionHandler:(void (^)(NSData *data))completionHandler {
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error when loading images %@",error.userInfo);
        } else {
        completionHandler(data);
        }
    }];
    task.priority=NSURLSessionTaskPriorityHigh;
    [task resume];
    return task;
}


@end
