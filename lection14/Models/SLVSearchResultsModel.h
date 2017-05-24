//
//  searchResultsModel.h
//  lection14
//
//  Created by iOS-School-1 on 04.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLVNetworkManager.h"
#import "SLVItem.h"

@interface SLVSearchResultsModel : NSObject

@property (copy,nonatomic) NSArray<SLVItem *> *items;
@property (strong,nonatomic) NSMutableArray *activeDownloads;
@property (strong,nonatomic) SLVNetworkManager *networkManager;

- (void) getItemsForRequest:(NSString *)request withCompletionHandler: (void (^)(void))completionHandler;
- (void) startIconDownload:(SLVItem *)currentItem forIndexPath:(NSIndexPath *)indexPath;

@end
