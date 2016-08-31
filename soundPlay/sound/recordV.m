//
//  recordV.m
//  soundPlay
//
//  Created by 刘志德 on 16/8/30.
//  Copyright © 2016年 LZD. All rights reserved.
//

#import "recordV.h"
#import "VoiceConverter.h"

@interface recordV()<soundRecordDelegate>
{
    //录音器
    soundRecord *ysxRecord;
    
    //录音时间
    float recordTotalTime;
    
    //录音状态图像
    UIView *backView;
    UIImageView *imgView;
    UILabel *titleLabel;
    UILabel *timeLabel;
    NSTimer *recordTime;
    
}
@end
@implementation recordV
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
        //初始化录音器
        ysxRecord =[[soundRecord alloc]init];
        ysxRecord.delegate =self;
        
    }
    return self;
}


#pragma mark - 私有方法
//开始录音
- (void)recordButtonTouchDown
{
    timeLabel.text = @"录音: 0\"";
    imgView.image = [UIImage imageNamed:@"mic_0.png"];
    recordTotalTime = 0;
    recordTime = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateView) userInfo:nil repeats:YES];
    [[self appRootViewController].view addSubview:backView];
    [ysxRecord startRecord];
}
//结束录音
- (void)recordButtonTouchUpInside
{
    if (recordTotalTime>1) {
        [backView removeFromSuperview];
        [ysxRecord stopRecord];
        [recordTime invalidate];
    }else{
        
        [backView removeFromSuperview];
        [ysxRecord cancleRecord];
        [recordTime invalidate];
        NSLog(@"录音时间过短");
    }
    
}
//取消录音
- (void)recordButtonTouchUpOutside
{
    [backView removeFromSuperview];
    [ysxRecord cancleRecord];
    [recordTime invalidate];
}
//手指离开按钮范围
- (void)recordDragOutside
{
    titleLabel.text = @"松手取消录音";
    
}

//手指回到按钮范围
- (void)recordDragInside
{
    titleLabel.text = @"上滑取消录音";
}
//获取最顶端显示的VC
- (UIViewController *)appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

// 更新时间和音量
- (void)updateView
{
    
    [ysxRecord.ysxRecord updateMeters];
    recordTotalTime +=0.1;
    if (self.maxTime>0)
    {
        timeLabel.text = [NSString stringWithFormat:@"录音: %d|%ld\"S",(int)recordTotalTime,(long)self.maxTime];
    }else{
        timeLabel.text = [NSString stringWithFormat:@"录音: %d\"",(int)recordTotalTime];
    }
    int lowPassResults = (int)(pow(10, (0.05 * [ysxRecord.ysxRecord peakPowerForChannel:0]))*10);
    NSString *imageName ;
    if (lowPassResults>6) {
        imageName = @"mic_6.png";
    }else{
        imageName = [NSString stringWithFormat:@"mic_%d.png",lowPassResults];
    }
    imgView.image = [UIImage imageNamed:imageName];
    if (self.maxTime>0&&recordTotalTime>self.maxTime) {
        [self recordButtonTouchUpInside];
    }
}

#pragma mark - 代理相关
- (void)soundRecordFinsh:(soundRecord *)soundRecord withFile:(NSString *)file
{
    if ([self.delegate respondsToSelector:@selector(recordSuccess:withFile:soundTime:)]) {
        if (self.switchAmr) {
            //转换amr格式
            NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *soundPathWav=[urlStr stringByAppendingPathComponent:@"ysxtemp.wav"];
            NSString *soundPathAmr=[urlStr stringByAppendingPathComponent:@"ysxtemp.amr"];
            if ([VoiceConverter ConvertWavToAmr:soundPathWav amrSavePath:soundPathAmr]) {
                [self.delegate recordSuccess:self withFile:soundPathAmr soundTime:recordTotalTime];
            }else{
                if ([self.delegate respondsToSelector:@selector(recordFail:withError:)]) {
                    [self.delegate recordFail:self withError:soundRecordErrorRecord];
                }
            }
        }else{
            [self.delegate recordSuccess:self withFile:file soundTime:recordTotalTime];
        }
        
        
        
    }
}
- (void)soundRecordError:(soundRecord *)soundRecord withError:(soundRecordtype)error
{
    [backView removeFromSuperview];
    [ysxRecord cancleRecord];
    [recordTime invalidate];
    if ([self.delegate respondsToSelector:@selector(recordFail:withError:)]) {
        [self.delegate recordFail:self withError:error];
    }
}
#pragma mark - 初始化
- (void)setUI
{
    [self setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self setTitle:@"松开 结束" forState:UIControlStateHighlighted];
    [self addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    //手指向上滑动取消录音
    [self addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    //松开手指完成录音
    [self addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    //手指离开按钮范围
    [self addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragExit];
    //手指回到按钮范围
    [self addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragEnter];
    
    //录音显示画面
    backView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    //        backView.backgroundColor = [UIColor blueColor];
    
    
    imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mic_0.png"]];
    imgView.frame = CGRectMake(0, 0, 154, 180);
    imgView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
    imgView.layer.cornerRadius = 10.0f;
    imgView.clipsToBounds = YES;
    
    
    if (!titleLabel){
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 40)];
        titleLabel.backgroundColor = [UIColor clearColor];
    }
    titleLabel.center = CGPointMake(imgView.center.x, imgView.center.y + 65);
    titleLabel.text = @"上滑取消录音";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    titleLabel.textColor = [UIColor whiteColor];
    
    if (!timeLabel) {
        timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 40)];
        timeLabel.backgroundColor = [UIColor clearColor];
    }
    timeLabel.center = CGPointMake(imgView.center.x, imgView.center.y - 77);
    timeLabel.text = @"录音: 0\"";
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.font = [UIFont boldSystemFontOfSize:14];
    timeLabel.textColor = [UIColor whiteColor];
    
    [backView addSubview:imgView];
    [backView addSubview:titleLabel];
    [backView addSubview:timeLabel];
}
@end
