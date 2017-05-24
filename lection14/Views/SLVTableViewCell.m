//
//  TableViewCell.m
//  lection14
//
//  Created by iOS-School-1 on 04.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "SLVTableViewCell.h"
#import "Masonry/Masonry.h"

@implementation SLVTableViewCell

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if(self) {
        _trackName = [UILabel new];
        _photoImageView = [UIImageView new];
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicator.hidden = YES;
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.center = self.contentView.center;
        
        _photoImageView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
        [self.contentView addSubview:_photoImageView];
        [self.contentView addSubview:_activityIndicator];
    }
    return self;
}

- (void)updateConstraints {
    [self.photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(self.contentView.mas_width).sizeOffset(CGSizeMake(-8, -8));
        self.photoImageView.layer.cornerRadius=20;
        self.photoImageView.layer.masksToBounds = YES;
    }];
    [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.photoImageView.mas_centerX);
        make.centerY.equalTo(self.photoImageView.mas_centerY);
    }];
    [super updateConstraints];
}

- (void)prepareForReuse {
    self.photoImageView.image = nil;
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}


@end
