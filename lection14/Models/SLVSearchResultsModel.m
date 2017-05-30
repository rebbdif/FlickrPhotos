//
//  searchResultsModel.m
//  lection14
//
//  Created by iOS-School-1 on 04.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "SLVSearchResultsModel.h"
#import "ImageDownloadOperation.h"
#import "SLVImageProcessing.h"
#import "SLVNetworkManager.h"

@interface SLVSearchResultsModel() <NSURLSessionDownloadDelegate>

@property (assign, nonatomic) NSUInteger page;
@property (strong, nonatomic) NSMutableDictionary<NSIndexPath *, ImageDownloadOperation *> *imageOperations;
@property (strong, nonatomic) NSOperationQueue *imagesQueue;
@property (strong, nonatomic) SLVNetworkManager *networkManager;
@property (strong, nonatomic) NSURLSession *session;

@end

@implementation SLVSearchResultsModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageOperations = [NSMutableDictionary new];
        _imagesQueue = [NSOperationQueue new];
        _imagesQueue.name = @"imagesQueue";
        _imagesQueue.qualityOfService = QOS_CLASS_DEFAULT;
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        _imageCache = [NSCache new];
        _page = 1;
        _items = [NSArray new];
    }
    return self;
}

- (void)getItemsForRequest:(NSString*) request withCompletionHandler:(void (^)(void))completionHandler {
    NSString *normalizedRequest = [request stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *escapedString = [normalizedRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *apiKey = @"&api_key=6a719063cc95dcbcbfb5ee19f627e05e";
    NSString *urls = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&per_page=10&tags=%@%@&page=%lu",escapedString,apiKey,self.page];
    NSURL *url = [NSURL URLWithString:urls];
    [SLVNetworkManager getModelWithSession:self.session fromURL:url withCompletionHandler:^(NSDictionary *json) {
        NSArray *newItems = [self parseData:json];
        self.items = [self.items arrayByAddingObjectsFromArray:newItems];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler();
        });
    }];
    self.page++;
}

- (NSArray *)parseData:(NSDictionary *)json {
    if (json) {
        NSMutableArray *parsingResults = [NSMutableArray new];
        for (NSDictionary * dict in json[@"photos"][@"photo"]) {
            [parsingResults addObject:[SLVItem itemWithDictionary:dict]];
        }
        return [parsingResults copy];
    } else {
        return nil;
    }
}

- (void)loadImageForIndexPath:(NSIndexPath *)indexPath withCompletionHandler:(void(^)(void))completionHandler {
    SLVItem *currentItem = self.items[indexPath.row];
    if (![self.imageCache objectForKey:currentItem.photoURL]) {
        if (!self.imageOperations[indexPath]) {
            ImageDownloadOperation *imageDownloadOperation = [ImageDownloadOperation new];
            imageDownloadOperation.indexPath = indexPath;
            imageDownloadOperation.item = currentItem;
            imageDownloadOperation.session = self.session;
            imageDownloadOperation.imageCache = self.imageCache;
            imageDownloadOperation.name = [NSString stringWithFormat:@"imageDownloadOperation for index %lu",indexPath.row];
            imageDownloadOperation.completionBlock = ^{
                completionHandler();
            };
            [self.imageOperations setObject:imageDownloadOperation forKey:indexPath];
            [self.imagesQueue addOperation:imageDownloadOperation];
        } else {
            if (self.imageOperations[indexPath].status == SLVImageStatusCancelled || self.imageOperations[indexPath].status == SLVImageStatusNone) {
                [self.imageOperations[indexPath] resume];
            }
        }
    } else {
        completionHandler();
    }
}

- (void)filterItemAtIndexPath:(NSIndexPath *)indexPath filter:(BOOL)filter withCompletionBlock:(void(^)(UIImage *image)) completion {
    if (filter == YES) {
        SLVItem *currentItem = self.items[indexPath.row];
        currentItem.applyFilterSwitherValue = YES;
        NSOperation *filterOperation = [NSBlockOperation blockOperationWithBlock:^{
                UIImage *filteredImage = [SLVImageProcessing applyFilterToImage:[self.imageCache objectForKey:indexPath]];
                completion(filteredImage);
        }];
        [filterOperation addDependency:[self.imageOperations objectForKey:indexPath]];
        [self.imagesQueue addOperation:filterOperation];
        NSLog(@"state changed for indexpath %lu",indexPath.row);
    } else {
        self.items[indexPath.row].applyFilterSwitherValue = NO;
        UIImage *originalImage = [self.imageCache objectForKey:indexPath];
        completion(originalImage);
        NSLog(@"state changed for indexpath %lu",indexPath.row);
    }
}

- (void)cancelOperations {
    [self.imageOperations enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id object, BOOL *stop) {
        ImageDownloadOperation *operation = (ImageDownloadOperation *)object;
        if (operation.isExecuting) {
            [operation pause];
        }
    }];
}

- (void)clearModel {
    self.items = [NSArray new];
    [self.imageCache removeAllObjects];
    self.page = 0;
    [self.imageOperations removeAllObjects];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    dispatch_async(dispatch_get_main_queue(), ^{
        //    self.progressView.progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
}

@end
