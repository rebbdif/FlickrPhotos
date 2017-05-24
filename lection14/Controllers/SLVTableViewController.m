//
//  TableViewController.m
//  lection14
//
//  Created by iOS-School-1 on 04.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "SLVTableViewController.h"
#import "SLVSearchResultsModel.h"
#import "SLVItem.h"
#import "SLVTableViewController.h"
#import "SLVTableViewCell.h"
#import "ImageDownloadOperation.h"

@interface SLVTableViewController () <UISearchBarDelegate, NetworkManagerDownloadDelegate>

@property (strong,nonatomic) SLVSearchResultsModel *model;
@property (strong,nonatomic) UISearchBar *searchBar;
@property (strong,nonatomic) NSString *searchRequest;
@property (strong,nonatomic) NSMutableDictionary<NSIndexPath *, NSOperation *>  *imageOperations;
@property (strong,nonatomic) NSOperationQueue *imagesQueue;

@end

@implementation SLVTableViewController

static  NSString *const reuseID = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.model = [SLVSearchResultsModel new];
    self.model.networkManager.downloadProgressDelegate = self;
    _imageOperations = [NSMutableDictionary new];
    _imagesQueue = [NSOperationQueue new];
    _imagesQueue.qualityOfService = QOS_CLASS_DEFAULT;
    
    self.searchBar=[UISearchBar new];
    self.searchBar.placeholder = @"Введите поисковый запрос";
    self.tableView.tableHeaderView = self.searchBar;
    self.searchBar.delegate = self;
    [self.searchBar becomeFirstResponder];
    [self.tableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
    [self.searchBar sizeToFit];
    
    [self.tableView registerClass:[SLVTableViewCell class] forCellReuseIdentifier:reuseID];
    self.tableView.rowHeight = 340;
    ///
    [self.searchBar endEditing:YES];
    __weak typeof(self) weakself = self;
    [self.model getItemsForRequest:@"tree" withCompletionHandler:^{
        [weakself.tableView reloadData];
    }];
    
}

#pragma mark - Search Bar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchRequest = searchBar.text;
    [searchBar endEditing:YES];
    if (self.searchRequest) {
        __weak typeof(self) weakself = self;
        [self.model getItemsForRequest:self.searchRequest withCompletionHandler:^{
            [weakself.tableView reloadData];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.items.count ? self.model.items.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SLVTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: reuseID forIndexPath:indexPath];
    SLVItem *currentItem = self.model.items[indexPath.row];
    if (!currentItem.photo) {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
            [self loadImageForIndexPath:indexPath];
        }
        cell.activityIndicator.hidden = NO;
        [cell.activityIndicator startAnimating];
    } else {
        cell.photoImageView.image = currentItem.photo;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)loadImageForIndexPath:(NSIndexPath *)indexPath {
    SLVItem *currentItem = self.model.items[indexPath.row];
    if (!currentItem.photo) {
        if (!self.imageOperations[indexPath]) {
            ImageDownloadOperation *imageDownloadOperation = [ImageDownloadOperation new];
            imageDownloadOperation.indexPath = indexPath;
            imageDownloadOperation.item = currentItem;
            imageDownloadOperation.networkManager = self.model.networkManager;
            imageDownloadOperation.completionBlock = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    SLVTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    cell.photoImageView.image = currentItem.photo;
                    [cell.activityIndicator stopAnimating];
                });
            };
            [self.imageOperations setObject:imageDownloadOperation forKey:indexPath];
            [self.imagesQueue addOperation:imageDownloadOperation];
        }
    }
}

- (void)loadImagesForOnscreenRows {
    if (self.model.items.count > 0) {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths) {
            [self loadImageForIndexPath:indexPath];
        }
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnscreenRows];
}

#pragma mark - downloadProgressDelegate

- (void)updateProgress {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    for (SLVItem *item in self.model.items) {
        item.photo = nil;
    }
}

@end
