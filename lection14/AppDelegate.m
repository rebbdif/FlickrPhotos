//
//  AppDelegate.m
//  lection14
//
//  Created by iOS-School-1 on 04.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AppDelegate.h"
#import "SLVTableViewController.h"
#import "SLVSearchResultsModel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    SLVSearchResultsModel *model = [SLVSearchResultsModel new];
    SLVTableViewController *tableVC=[[SLVTableViewController alloc]initWithModel:model];
    self.window.rootViewController=tableVC;
    [self.window makeKeyAndVisible];
    return YES;
}
@end
