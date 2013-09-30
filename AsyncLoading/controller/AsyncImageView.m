//
//  AsyncImageView.m
//  AsyncLoading
//
//  Created by 大竹 雅登 on 2013/09/30.
//  Copyright (c) 2013年 Masato. All rights reserved.
//

#import "AsyncImageView.h"

@interface AsyncImageView ()
{
    UIActivityIndicatorView *indicatorView;
}

@property (nonatomic, strong) NSURLConnection *aConnection;
@property (nonatomic, strong) NSMutableData *receivedData;

@end

@implementation AsyncImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)loadImage:(NSString *)url {
    
    _receivedData = [[NSMutableData alloc] initWithCapacity:0];
    
	NSURLRequest *req = [NSURLRequest
						 requestWithURL:[NSURL URLWithString:url]
						 cachePolicy:NSURLRequestUseProtocolCachePolicy
						 timeoutInterval:30.0];
	_aConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    // indicatorを生成
    indicatorView = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:indicatorView];
    indicatorView.center = self.center;
    [indicatorView startAnimating];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[_receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // 読み込んだ画像をセット
	self.image = [UIImage imageWithData:_receivedData];
    
    // indicatorを取り除く
    [indicatorView removeFromSuperview];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Failed");
    
    // indicatorを取り除く
    [indicatorView removeFromSuperview];
}

@end
