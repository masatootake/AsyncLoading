//
//  CacheAsyncTableController.m
//  AsyncLoading
//
//  Created by 大竹 雅登 on 2013/09/30.
//  Copyright (c) 2013年 Masato. All rights reserved.
//

#import "CacheAsyncTableController.h"

#import "Downloader.h"

@interface CacheAsyncTableController ()

@property (nonatomic, strong) NSMutableDictionary *imageCache;
@property (nonatomic, strong) NSMutableDictionary *downloaderManager;

@end

@implementation CacheAsyncTableController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    // 非同期表示・キャッシュ用の配列の初期化
    self.imageCache = [NSMutableDictionary dictionary];
    self.downloaderManager = [NSMutableDictionary dictionary];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ([_imageCache objectForKey:indexPath]) {
        // すでにキャッシュしてある場合
        cell.imageView.image = [_imageCache objectForKey:indexPath];
    } else {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            // キャッシュがない場合、読み込む
            [self startIconDownload:indexPath];
        }
    }
    
    return cell;
}

//--------------------------------------------------------------//
#pragma mark - Downloader
// 参考URL: http://kkinukawa.hatenablog.com/entry/20110327/1301219131
//--------------------------------------------------------------//

- (void)startIconDownload:(NSIndexPath *)indexPath
{
    NSString *imageURL = @"http://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Apple_Computer_Logo_rainbow.svg/150px-Apple_Computer_Logo_rainbow.svg.png";
    
    Downloader *iconDownloader = [[Downloader alloc] init];
    iconDownloader.delegate = self;
    
    [iconDownloader get:[NSURL URLWithString:imageURL]];
    iconDownloader.identifier = indexPath;
    [_downloaderManager setObject:iconDownloader forKey:indexPath];
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {
        if(![_imageCache objectForKey:indexPath]){
            [self startIconDownload:indexPath];
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
-(void)downloader:(NSURLConnection *)conn didLoad:(NSMutableData *)data identifier:(id)identifier{
    NSIndexPath *indexPath = identifier;

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil) {
        // ダウンロードのインスタンスを削除する
        [_downloaderManager removeObjectForKey:indexPath];
        
        // セルに画像をセット
        cell.imageView.image = [UIImage imageWithData:data];
        // キャッシュに追加
        [_imageCache setObject:[UIImage imageWithData:data] forKey:indexPath];
    }
    
    // セルを更新
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

@end
