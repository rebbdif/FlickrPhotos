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

@property (strong, nonatomic) UIImageView *photoImageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (assign, nonatomic, readonly) CGSize imageViewSize;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UISwitch *applyFilterSwitch;
@property (strong, nonatomic) UILabel *applyFilterLabel;

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id<CellDelegate> delegate;

@end
