//
//  SLVTableViewControllerDataSource.h
//  lection14
//
//  Created by 1 on 27.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLVTableViewController.h"
@import UIKit;

@class SLVSearchResultsModel;

@interface SLVTableViewControllerDataProvider : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;

- (instancetype)initWithModel:(id<SLVTableVCDelegate>)model;

@end
