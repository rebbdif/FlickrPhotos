//
//  TableViewController.h
//  lection14
//
//  Created by iOS-School-1 on 04.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  SLVTableVCDelegate<NSObject>

@end

@interface SLVTableViewController : UITableViewController

- (instancetype)initWithModel:(id<SLVTableVCDelegate>)model;

@end
