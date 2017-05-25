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
@property (strong,nonatomic) NSMutableDictionary<NSIndexPath *, ImageDownloadOperation *>  *imageOperations;
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
    self.tableView.allowsSelection = NO;
    self.searchBar.delegate = self;
    [self.searchBar becomeFirstResponder];
    [self.tableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
    [self.searchBar sizeToFit];
    
    [self.tableView registerClass:[SLVTableViewCell class] forCellReuseIdentifier:reuseID];
    self.tableView.rowHeight = 368;
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
        [self.imageOperations removeAllObjects];
        [self.model clearModel];
        __weak typeof(self) weakself = self;
        [self.model getItemsForRequest:self.searchRequest withCompletionHandler:^{
            [weakself.tableView reloadData];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.model.items.count == 0 ? 0 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.items.count == 0 ? 0 : self.model.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SLVTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: reuseID forIndexPath:indexPath];
    SLVItem *currentItem = self.model.items[indexPath.row];
    [cell.applyFilterSwitch addTarget:self action:@selector(applyFilterSwitherValueChanged:) forControlEvents:UIControlEventValueChanged];
    cell.applyFilterSwitch.tag = indexPath.row;
    if (![self.model.imageCache objectForKey:currentItem.photoURL]) {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
            [self loadImageForIndexPath:indexPath];
        }
        cell.activityIndicator.hidden = NO;
        [cell.activityIndicator startAnimating];
        cell.progressView.hidden = NO;
        cell.progressView.progress = 0.5;
    } else {
        cell.photoImageView.image = [self.model.imageCache objectForKey:currentItem.photoURL];
    }
    return cell;
}

- (void)loadImageForIndexPath:(NSIndexPath *)indexPath {
    SLVItem *currentItem = self.model.items[indexPath.row];
    if (![self.model.imageCache objectForKey:currentItem.photoURL]) {
        if (!self.imageOperations[indexPath]) {
            ImageDownloadOperation *imageDownloadOperation = [ImageDownloadOperation new];
            imageDownloadOperation.indexPath = indexPath;
            imageDownloadOperation.item = currentItem;
            imageDownloadOperation.networkManager = self.model.networkManager;
            imageDownloadOperation.imageCache = self.model.imageCache;
            imageDownloadOperation.completionBlock = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    SLVTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    cell.photoImageView.image = [self.model.imageCache objectForKey: currentItem.photoURL];
                    [cell.activityIndicator stopAnimating];
                    cell.progressView.hidden = YES;
                });
            };
            [self.imageOperations setObject:imageDownloadOperation forKey:indexPath];
            [self.imagesQueue addOperation:imageDownloadOperation];
        } else {
            [self.imageOperations[indexPath] resume];
        }
    } else {
        SLVTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.photoImageView.image = [self.model.imageCache objectForKey:currentItem.photoURL];
        [cell.activityIndicator stopAnimating];
        cell.progressView.hidden = YES;
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.imageOperations enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id object, BOOL *stop) {
        ImageDownloadOperation *operation = (ImageDownloadOperation *)object;
        [operation cancel];
    }];
}

#pragma mark - downloadProgressDelegate

- (void)updateProgress {
    
}

- (IBAction)applyFilterSwitherValueChanged:(UISwitch *)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    if (sender.on) {
        NSLog(@"state changed for indexpath %lu",indexPath.row);
    } else {
        NSLog(@"state changed for indexpath %lu",indexPath.row);
    }
}


@end
