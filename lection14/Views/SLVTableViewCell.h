//
//  TableViewCell.h
//  lection14
//
//  Created by iOS-School-1 on 04.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellDelegate <NSObject>

- (void)didClickSwitch:(UISwitch *)switcher atIndexPath:(NSIndexPath *)indexPath;

@end

@interface SLVTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UISwitch *applyFilterSwitch;
@property (nonatomic, strong) UILabel *applyFilterLabel;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<CellDelegate> delegate;

@end
