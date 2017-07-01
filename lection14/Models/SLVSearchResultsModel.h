//
//  searchResultsModel.h
//  lection14
//
//  Created by iOS-School-1 on 04.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLVItem.h"

@class SLVImageDownloadOperation;
@class SLVNetworkManager;

typedef void(^voidBlock)(void);

@interface SLVSearchResultsModel : NSObject

@property (nonatomic, copy) NSArray<SLVItem *> *items;
@property (nonatomic, copy) NSString *searchRequest;
@property (nonatomic, copy) NSCache *imageCache;

- (void)getItemsForRequest:(NSString *)request withCompletionHandler:(voidBlock)completionHandler;
- (void)loadImageForIndexPath:(NSIndexPath *)indexPath withCompletionHandler:(voidBlock)completionHandler;
- (void)pauseOperations;
- (void)filterItemAtIndexPath:(NSIndexPath *)indexPath filter:(BOOL)filter withCompletionBlock:(void(^)(UIImage *image))completion;
- (void)clearModel;

@end
