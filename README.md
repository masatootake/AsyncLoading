URLから画像を非同期に読み込む3種類の実装
============

URLから画像を生成するときは、普通に実装すると以下のようになります。

```ViewController.m
NSURL *url = [NSURL URLWithString:@"画像のURL"];
NSData *data = [NSData dataWithContentsOfURL:url];
UIImage *image = [UIImage imageWithData:data];
```

しかし、この実装だとシングルスレッドで読み込むので、その間他の処理が止まり固まったように見えてしまいます。
なので、画像は非同期に読み込むことが必要になります。今回は非同期での画像読み込みの実装を3種類してみました。
3つの実装をまとめたソースコードは、[こちらからダウンロード](https://github.com/EntreGulss/AsyncLoading)してください。

1. **一度読み込んだ画像をキャッシュしない。（UITableViewCellの画像）**
2. **一度読み込んだ画像をキャッシュして、再び読み込まない。（UITableViewCellの画像）**
3. **UIImageViewのインスタンスに読み込み処理を任せて、それぞれで読み込む。（UIImageView）**

## 1. 一度読み込んだ画像をキャッシュしない。

参考URL: [ネット上の画像を表示させた UITableView をぬるぬる動作させる方法](http://rakuishi.com/iossdk/3881/)

```UncacheAsyncTableController.m
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // この部分が重要
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q_main = dispatch_get_main_queue();
    cell.imageView.image = nil;
    dispatch_async(q_global, ^{
        NSString *imageURL = @"http://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Apple_Computer_Logo_rainbow.svg/150px-Apple_Computer_Logo_rainbow.svg.png";
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: imageURL]]];
        
        dispatch_async(q_main, ^{
            cell.imageView.image = image;
            [cell layoutSubviews];
        });
    });
    
    return cell;
}
```

## 2. 一度読み込んだ画像をキャッシュして、再び読み込まない。
参考URL: [UITableViewの要素を非同期に設定する](http://kkinukawa.hatenablog.com/entry/20110327/1301219131)

以下のクラスを組み込んで下さい。

* Downloader.h （非ARC）
* Downloader.m （非ARC）

```CacheAsyncTableController.h
#import "Downloader.h"

@interface CacheAsyncTableController : UITableViewController

@property (nonatomic, strong) NSMutableDictionary *imageCache;
@property (nonatomic, strong) NSMutableDictionary *downloaderManager;

@end
```

```CacheAsyncTableController.m
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 非同期表示・キャッシュ用の配列の初期化
    self.imageCache = [NSMutableDictionary dictionary];
    self.downloaderManager = [NSMutableDictionary dictionary];
}

***（略）***

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


***（略）***

// 以下のメソッドを実装する（ソースコード参照）
- (void)startIconDownload:(NSIndexPath *)indexPath;
- (void)loadImagesForOnscreenRows;
- (void)downloader:(NSURLConnection *)conn didLoad:(NSMutableData *)data identifier:(id)identifier;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

```

## 3. UIImageViewのインスタンスに読み込み処理を任せて、それぞれで読み込む。

参考URL: [非同期通信で画像をロードする方法について](http://d.hatena.ne.jp/ntaku/20091031/1256977032)

以下のクラスを組み込んで下さい。

* AsyncImageView.h
* AsyncImageView.m

UIImageViewを生成するところで、以下のように書きます。

```AsyncImageViewController.m
AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
NSString *imageURL = @"http://upload.wikimedia.org/wikipedia/commons/a/a5/Apple_gray_logo.png";
[imageView loadImage:imageURL]; // 画像を非同期で読み込む
```



