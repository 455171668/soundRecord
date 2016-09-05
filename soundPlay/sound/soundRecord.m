//
//  soundRecord.m
//  soundPlay
//
//  Created by 刘志德 on 16/8/30.
//  Copyright © 2016年 LZD. All rights reserved.
//

#import "soundRecord.h"
#import "VoiceConverter.h"

@interface soundRecord ()<AVAudioRecorderDelegate>
{
    //录音是否正常停止
    BOOL isStop;
}
@end
@implementation soundRecord
static soundRecord *_record;


#pragma mark - 录音器初始化
/**
 *  设置音频会话
 */
-(void)setAudioSession{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    NSError *sessionError;
    
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride
                             );
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
}

- (AVAudioRecorder *)ysxRecord
{
    if (!_ysxRecord) {
        [self setAudioSession];
        //获取音频文件存储路径
        NSURL *recordUrl = [self recordUrl];
        //获取录音器配置  配置统一才能转换amr正常
        NSDictionary *recordDic = [VoiceConverter GetAudioRecorderSettingDict];
        //初始化录音器
        NSError *recordError;
        _ysxRecord = [[AVAudioRecorder alloc]initWithURL:recordUrl settings:recordDic error:&recordError];
        _ysxRecord.delegate = self;
        //检测声波，设置yes
        _ysxRecord.meteringEnabled = YES;
        if (recordError) {
            return nil;
        }
    }
    return _ysxRecord;
    
}


- (NSURL *)recordUrl
{
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:@"ysxtemp.wav"];
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}

#pragma mark - 录音开始
- (void)startRecord
{
    isStop = NO;
    //判断该应用是否有麦克风权限
    if ([[AVAudioSession sharedInstance]respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance]performSelector:@selector(requestRecordPermission:) withObject:^(BOOL isCanRecord){
            if (!isCanRecord) {
                if ([self.delegate respondsToSelector:@selector(soundRecordError:withNots:)]) {
                    [self.delegate soundRecordError:self withError:soundRecordErrorAuthority];
                }
                return ;
            }
        }];
    }
    //判断录音器是否正常，开始录音
    if (self.ysxRecord) {
        [self.ysxRecord stop];
        [self.ysxRecord prepareToRecord];
        [self.ysxRecord record];
    }else{
        if ([self.delegate respondsToSelector:@selector(soundRecordError:withNots:)]) {
            [self.delegate soundRecordError:self withError:soundRecordErrorInit];
        }
    }
    
}

#pragma mark - 录音结束
- (void)stopRecord
{
    isStop = YES;
    if (self.ysxRecord) {
        [self.ysxRecord stop];
    }
}
- (void)cancleRecord
{
    if (self.ysxRecord) {
        [self.ysxRecord stop];
    }
}
#pragma mark - 代理相关
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (isStop) {
        if ([self.delegate respondsToSelector:@selector(soundRecordFinsh:withFile:)]) {
            
            NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *soundPathWav=[urlStr stringByAppendingPathComponent:@"ysxtemp.wav"];
            NSString *soundPathAmr=[urlStr stringByAppendingPathComponent:@"ysxtemp.amr"];
            if ([VoiceConverter ConvertWavToAmr:soundPathWav amrSavePath:soundPathAmr]) {
                [self.delegate soundRecordFinsh:self withFile:soundPathAmr];
            }else{
                if ([self.delegate respondsToSelector:@selector(soundRecordError:withNots:)]) {
                    [self.delegate soundRecordError:self withError:soundRecordErrorRecord];
                }
            }
            
        }
    }
    
}
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                   error:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(soundRecordError:withNots:)]) {
        [self.delegate soundRecordError:self withError:soundRecordErrorRecord];
    }
}
@end
