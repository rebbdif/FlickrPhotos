//
//  searchResultsModel.m
//  lection14
//
//  Created by iOS-School-1 on 04.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "SLVSearchResultsModel.h"

@implementation SLVSearchResultsModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _networkManager = [SLVNetworkManager new];
        _imageCache = [NSCache new];
    }
    return self;
}

- (void)getItemsForRequest:(NSString*) request withCompletionHandler:(void (^)(void))completionHandler {
    NSString *normalizedRequest=[request stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *escapedString = [normalizedRequest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *apiKey = @"&api_key=6a719063cc95dcbcbfb5ee19f627e05e";
    NSString *urls =[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&text=%@%@",escapedString,apiKey];
    NSURL *url =[NSURL URLWithString:urls];
    [self.networkManager getModelFromURL:url withCompletionHandler:^(NSData *data) {
        self.items=[self parseData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler();
        });
    }];
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
}

-(void)dealloc {
    _networkManager=nil;
}

@end
