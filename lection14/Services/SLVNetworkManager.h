//
//  NetworkManager.h
//  lection14
//
//  Created by iOS-School-1 on 04.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetworkManagerDownloadDelegate <NSObject>

@optional

- (void)updateProgress;
- (void)downloadedImageData;

@end

@interface SLVNetworkManager : NSObject

@property (strong,nonatomic) NSURLSession *session;
@property (weak,nonatomic) id downloadProgressDelegate;

- (void)getModelFromURL:(NSURL *) url withCompletionHandler:(void (^)(NSData * data))completionHandler;
- (NSURLSessionDataTask *)downloadImageFromURL:(NSURL *)url withCompletionHandler:(void (^)(NSData *data))completionHandler;

@end
