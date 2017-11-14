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
#import "MYCircleBar.h"
@interface ViewController () <MYCircleBarDelegate>

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
    self.labeledCircleProgressView.progressTintColor = [UIColor redColor];//进度条的颜色
    self.labeledCircleProgressView.trackTintColor = [UIColor purpleColor];//类似于背景颜色
    self.labeledCircleProgressView.innerTintColor = [UIColor yellowColor];
    self.labeledCircleProgressView.thicknessRatio = 1;//这个是显示对应的中间的是否镂空[0-1]

    MYCircleBar *circleBar = [MYCircleBar cireleBarframe:CGRectMake(30,300, self.view.frame.size.width - 60, 44) NarmalColor:[UIColor blackColor] disableColor:[UIColor yellowColor] titles:@[@"开始",@"暂停",@"继续"]];
    circleBar.delegate = self;
    circleBar.backgroundColor = [UIColor redColor];
    [self.view addSubview:circleBar];
}

- (IBAction)start:(id)sender {
    //1.需要根据的URL去判断对应的正在下载的，和下载完完成匹配是否存在如果存在则提示正在下载或者已经下载完毕
    DownLoader *downLoad = [[DownLoader alloc] init];
    self.loader = downLoad;
    [downLoad setLoadProgress:^(float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView setProgress:progress animated:true];
             //
            [self.labeledCircleProgressView setProgress:progress animated:true];
        });
    }];
    [downLoad setSpeed:^(NSString *speed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.percentLabel.text = speed;
        });
    }];
    [downLoad downLoadWithURL:[NSURL URLWithString:@"http://m7.music.126.net/20171110154630/be316fa526a5693b3539a5b0a528766c/ymusic/915c/bd30/a1ec/3645548e2e280813814f401b5d543d8c.mp3"]];
}
- (IBAction)resume:(id)sender {
    [self.loader resume];
}
- (IBAction)pause:(id)sender {
    [self.loader pause];
}

- (void)clickCircleBarAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            [self start:nil];
            break;
        case 1:
            [self pause:nil];
            break;
        case 2:
            [self resume:nil];
            break;
        default:
            break;
    }
}

@end
