//
//  ViewController.m
//  BreakPointDownLoad
//
//  Created by 满艺网 on 2017/11/8.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//

//NOTE: 点击退出后台的时候是暂停下载的，app激活的时候会继续上次的下载

#import "ViewController.h"
#import "DownLoader.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (nonatomic ,strong) DownLoader *loader;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)start:(id)sender {
    //1.需要根据的URL去判断对应的正在下载的，和下载完完成匹配是否存在如果存在则提示正在下载或者已经下载完毕
    DownLoader *downLoad = [[DownLoader alloc] init];
    self.loader = downLoad;
    [downLoad setLoadProgress:^(float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress;
            self.percentLabel.text = [NSString stringWithFormat:@"%.2f%%",progress * 100];
        });
    }];
    [downLoad downLoadWithURL:[NSURL URLWithString:@"http://m8.music.126.net/20171109183252/a7e37a44b00e2c6314657c927a1a29cf/ymusic/1cd1/461f/08f9/a16b3a55120adac00ae7a6e15f955f62.mp3"]];
}
- (IBAction)resume:(id)sender {
    [self.loader resume];
}
- (IBAction)pause:(id)sender {
    [self.loader pause];
}
@end
