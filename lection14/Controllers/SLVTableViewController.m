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
#import "SLVTableViewCell.h"
#import "SLVTableViewControllerDataProvider.h"

@interface SLVTableViewController () <UISearchBarDelegate>

@property (strong, nonatomic, readwrite) SLVSearchResultsModel *model;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) SLVTableViewControllerDataProvider *dataProvider;

@end

@implementation SLVTableViewController

static NSString *const reuseID = @"cell";

- (instancetype)initWithModel:(id<SLVTableVCDelegate>)model {
    self = [super init];
    if (self) {
        _model = model;
        _dataProvider = [[SLVTableViewControllerDataProvider alloc]initWithModel:model];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataProvider.tableView = self.tableView;
    self.tableView.delegate = _dataProvider;
    self.tableView.dataSource = _dataProvider;
    ((UIScrollView *)self.tableView).delegate = self;
    [self.tableView registerClass:[SLVTableViewCell class] forCellReuseIdentifier:reuseID];
    
    self.searchBar=[UISearchBar new];
    self.searchBar.placeholder = @"Введите поисковый запрос";
    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.allowsSelection = NO;
    self.searchBar.delegate = self;
    [self.searchBar becomeFirstResponder];
    [self.tableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
    [self.searchBar sizeToFit];
    
    self.tableView.rowHeight = 368;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgressNotification:) name:@"updateProgressNotification" object:nil];
    
    ///
    __weak typeof(self) weakself = self;
    [self.searchBar endEditing:YES];
    self.model.searchRequest = @"cat";
    [self.model getItemsForRequest:self.model.searchRequest withCompletionHandler:^{
        [weakself.tableView reloadData];
    }];
    ///
}

- (void)updateProgressNotification:(NSNotification *)notification {
    NSIndexPath *indexPath = notification.object;
    SLVTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        dispatch_async(dispatch_get_main_queue(), ^{
            SLVItem *currentItem = self.model.items[indexPath.row];
            cell.progressView.progress = currentItem.downloadProgress;
        });
    }
}

#pragma mark - Search Bar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.model.searchRequest = searchBar.text;
    [searchBar endEditing:YES];
    if (self.model.searchRequest) {
        [self.model clearModel];
        __weak typeof(self) weakself = self;
        [self.model getItemsForRequest:self.model.searchRequest withCompletionHandler:^{
            [weakself.tableView reloadData];
        }];
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
    [self.model cancelOperations];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row + 5 == self.model.items.count) {
        __weak typeof(self) weakself = self;
        [self.model getItemsForRequest:self.model.searchRequest withCompletionHandler:^{
            [weakself.tableView reloadData];
        }];
    }
}

- (void)loadImagesForOnscreenRows {
    if (self.model.items.count > 0) {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths) {
            [self.model loadImageForIndexPath:indexPath withCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    SLVTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    cell.photoImageView.image = [self.model.imageCache objectForKey:indexPath];
                    [cell.activityIndicator stopAnimating];
                    cell.progressView.hidden = YES;
                });
            }];
        }
    }
}

@end
