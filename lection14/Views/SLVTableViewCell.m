//
//  TableViewCell.m
//  lection14
//
//  Created by iOS-School-1 on 04.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "SLVTableViewCell.h"
#import "Masonry/Masonry.h"

@interface SLVTableViewCell()

@property (assign, nonatomic, readwrite) CGSize imageViewSize;

@end

@implementation SLVTableViewCell

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        _photoImageView = [UIImageView new];
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicator.hidden = YES;
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.center = self.contentView.center;
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        
        _photoImageView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
       // [_photoImageView setContentMode:UIViewContentModeScaleAspectFill];

        _applyFilterLabel = [UILabel new];
        _applyFilterLabel.text = @"Применить фильтры";
        _applyFilterSwitch = [UISwitch new];
        
        [self.contentView addSubview:_photoImageView];
        [self.contentView addSubview:_activityIndicator];
        [self.contentView addSubview:_progressView];
        [self.contentView addSubview:_applyFilterLabel];
        [self.contentView addSubview:_applyFilterSwitch];
    }
    return self;
}

- (void)updateConstraints {
    [self.photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY).with.offset(-12);
        make.size.mas_equalTo(self.contentView.mas_width).sizeOffset(CGSizeMake(-8, -8));
        self.photoImageView.layer.cornerRadius = 20;
        self.photoImageView.layer.masksToBounds = YES;
    }];
    [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.photoImageView.mas_centerX);
        make.centerY.equalTo(self.photoImageView.mas_centerY);
    }];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.left.equalTo(self.contentView.mas_left).with.offset(8);
        make.right.equalTo(self.contentView.mas_right).with.offset(-8);
    }];
    [self.applyFilterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.photoImageView.mas_bottom).with.offset(8);
        make.left.equalTo(self.contentView.mas_left).with.offset(10);
        make.right.equalTo(self.contentView.mas_right).with.offset(-60);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-8);
    }];
    [self.applyFilterSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.photoImageView.mas_bottom).with.offset(4);
        make.left.equalTo(self.applyFilterLabel.mas_right).with.offset(8);
        make.right.equalTo(self.photoImageView.mas_right).with.offset(-2);
    }];
    
    [super updateConstraints];
}

- (void)prepareForReuse {
    self.photoImageView.image = nil;
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    self.progressView.hidden = YES;
}


@end
