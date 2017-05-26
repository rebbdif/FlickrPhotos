//
//  searchResultsModel.m
//  lection14
//
//  Created by iOS-School-1 on 04.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "SLVSearchResultsModel.h"

@interface SLVSearchResultsModel()

@property (assign, nonatomic) NSUInteger page;

@end


@implementation SLVSearchResultsModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _networkManager = [SLVNetworkManager new];
        _imageCache = [NSCache new];
        _page = 1;
        _items = [NSArray new];
    }
    return self;
}

- (void)getItemsForRequest:(NSString*) request withCompletionHandler:(void (^)(void))completionHandler {
    NSString *normalizedRequest=[request stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *escapedString = [normalizedRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *apiKey = @"&api_key=6a719063cc95dcbcbfb5ee19f627e05e";
    NSString *urls =[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&per_page=10&tags=%@%@&page=%lu",escapedString,apiKey,self.page];
    NSURL *url =[NSURL URLWithString:urls];
    [self.networkManager getModelFromURL:url withCompletionHandler:^(NSData *data) {
        NSArray *newItems = [self parseData:data];
        self.items= [self.items arrayByAddingObjectsFromArray:newItems];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler();
        });
    }];
    self.page++;
}

- (NSArray *)parseData:(NSData *)data {
    if (!data) {
        return nil;
    } else {
        NSError *error=nil;
        NSDictionary* json=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if(error) {
            NSLog(@"ERROR PARSING JSON %@",error.userInfo);
        }
        
        NSMutableArray *parsingResults =[NSMutableArray new];
        for (NSDictionary * dict in json[@"photos"][@"photo"]) {
            [parsingResults addObject:[SLVItem itemWithDictionary:dict]];
        }
        return [parsingResults copy];
    }
}

- (void)clearModel {
    self.items = [NSArray new];
    [self.imageCache removeAllObjects];
    self.page = 0;
}

-(void)dealloc {
    _networkManager=nil;
}

@end
