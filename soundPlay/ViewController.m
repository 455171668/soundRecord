//
//  ViewController.m
//  soundPlay
//
//  Created by LIU on 16/8/30.
//  Copyright © 2016年 LZD. All rights reserved.
//

#import "ViewController.h"
#import "recordV.h"

@interface ViewController ()<recordVDelegate>
{
    //播放器
    AVPlayer *play;
    UIButton *playBtn;
    //音频文件路径
    NSString *soundFile;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    recordV *reee = [[recordV alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-300)*0.5, [UIScreen mainScreen].bounds.size.height - 200, 100, 50)];
    reee.delegate = self;
    reee.maxTime = 10;
    reee.switchAmr = YES;
    reee.backgroundColor = [UIColor redColor];
    [self.view addSubview:reee];
    
    playBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(reee.frame)+100, [UIScreen mainScreen].bounds.size.height - 200, 100, 50)];
    playBtn.backgroundColor = [UIColor redColor];
    [playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playBtnClike) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//播放录音
- (void)playBtnClike{
    if (soundFile!=nil&&soundFile.length>0) {
        NSURL *url = [NSURL fileURLWithPath:soundFile];
        play = [[AVPlayer alloc]initWithURL:url];
        [play play];
    }
    
    
}

#pragma mark - 录音代理

//录音成功，返回路径和录音时间
- (void)recordSuccess:(recordV *)recordV withFile:(NSString *)file soundTime:(int)soundTime
{
    soundFile  = file;
}
//录音失败，返回错误代码
- (void)recordFail:(recordV *)recordV withError:(soundRecordtype)Error
{
    
}
@end
