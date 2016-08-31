//
//  soundRecord.h
//  soundPlay
//
//  Created by LIU on 16/8/30.
//  Copyright © 2016年 LZD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
typedef enum
{
    soundRecordErrorAuthority,//权限错误
    soundRecordErrorInit,      //初始化错误
    soundRecordErrorRecord,    //录音失败
}soundRecordtype;

@class soundRecord;
@protocol soundRecordDelegate <NSObject>

@optional
//录音完成，返回路径
- (void)soundRecordFinsh:(soundRecord *)soundRecord withFile:(NSString *)file;
//error，错误提示
- (void)soundRecordError:(soundRecord *)soundRecord withError:(soundRecordtype)error;
@end
@interface soundRecord : NSObject
@property (nonatomic,strong)AVAudioRecorder *ysxRecord;
@property (nonatomic,assign)id<soundRecordDelegate> delegate;
//开始录音
- (void)startRecord;

//结束录音
- (void)stopRecord;

//取消录音
- (void)cancleRecord;
@end


