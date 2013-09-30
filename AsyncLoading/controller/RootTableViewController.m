//
//  RootTableViewController.m
//  AsyncLoading
//
//  Created by 大竹 雅登 on 2013/09/30.
//  Copyright (c) 2013年 Masato. All rights reserved.
//

#import "RootTableViewController.h"

#import "UncacheAsyncTableController.h"
#import "CacheAsyncTableController.h"
#import "AsyncImageViewController.h"

@interface RootTableViewController ()

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation RootTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    // set app name as title
    self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    // items
    _items = [NSMutableArray array];
    [_items addObject:@"キャッシュ無し非同期Cell"];
    [_items addObject:@"キャッシュあり非同期Cell"];
    [_items addObject:@"非同期読み込みUIImageView"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = _items[indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *controller;
    if (indexPath.row == 0) {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UncacheAsyncTableController"];
    }
    else if (indexPath.row == 1) {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CacheAsyncTableController"];
    }
    else if (indexPath.row == 2) {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"AsyncImageViewController"];
    }
    
    controller.title = _items[indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
    
}

@end
