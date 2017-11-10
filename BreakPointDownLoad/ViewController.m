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
#import <DALabeledCircularProgressView.h>
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet DALabeledCircularProgressView *labeledCircleProgressView;
@property (nonatomic ,strong) DownLoader *loader;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.labeledCircleProgressView.thicknessRatio = 0.3;
    self.labeledCircleProgressView.progressLabel.backgroundColor = [UIColor clearColor];
    self.labeledCircleProgressView.progressLabel.textColor = [UIColor blueColor];
    self.labeledCircleProgressView.progress = 0.3;
    self.labeledCircleProgressView.progressTintColor = [UIColor redColor];
    self.labeledCircleProgressView.trackTintColor = [UIColor purpleColor];
    self.labeledCircleProgressView.thicknessRatio = 1;
}

- (IBAction)start:(id)sender {
    //1.需要根据的URL去判断对应的正在下载的，和下载完完成匹配是否存在如果存在则提示正在下载或者已经下载完毕
    DownLoader *downLoad = [[DownLoader alloc] init];
    self.loader = downLoad;
    [downLoad setLoadProgress:^(float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView setProgress:progress animated:true];
//            self.labeledCircleProgressView.progressLabel.text =
            self.percentLabel.text = [NSString stringWithFormat:@"%.2f%%",progress * 100];
             //
            [self.labeledCircleProgressView setProgress:progress animated:true];
        });
    }];
    //http://p3.music.126.net/nJROWeZiEp1TUv27amRguQ==/18195817928618786.jpg?param=640y640&quality=100
    [downLoad downLoadWithURL:[NSURL URLWithString:@"http://m8.music.126.net/20171110114131/4fe5e30d2d7f176d2398cc76a5c3bdfc/ymusic/664f/130f/169f/ef97f4671de0dd8c0cef0cd87748b767.mp3"]];
}
- (IBAction)resume:(id)sender {
    [self.loader resume];
}
- (IBAction)pause:(id)sender {
    [self.loader pause];
}
@end
