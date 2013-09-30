//
//  AsyncImageViewController.m
//  AsyncLoading
//
//  Created by 大竹 雅登 on 2013/09/30.
//  Copyright (c) 2013年 Masato. All rights reserved.
//

#import "AsyncImageViewController.h"

#import "AsyncImageView.h"

@interface AsyncImageViewController ()

@end

@implementation AsyncImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // セルのクラスを登録する
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MyCell"];
    
    // Collectionの更新
    [self.collectionView reloadData];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    NSString *imageURL = @"http://upload.wikimedia.org/wikipedia/commons/a/a5/Apple_gray_logo.png";
    [imageView loadImage:imageURL]; // 画像を非同期で読み込む
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MyCell" forIndexPath:indexPath];
    [cell addSubview:imageView];
    return cell;
    
    // 同期で読み込む場合（すべてのセルの読み込み完了まで遷移できない）
    //imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
}


@end
