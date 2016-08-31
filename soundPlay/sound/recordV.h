//
//  recordV.h
//  soundPlay
//
//  Created by 刘志德 on 16/8/30.
//  Copyright © 2016年 LZD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "soundRecord.h"
@class recordV;
@protocol recordVDelegate <NSObject>

@optional
//录音成功，返回路径
- (void)recordSuccess:(recordV *)recordV withFile:(NSString *)file soundTime:(int)soundTime;
//录音失败，返回错误
- (void)recordFail:(recordV *)recordV withError:(soundRecordtype)Error;

@end
@interface recordV : UIButton
//最长录音时间，无限制则不传
@property (nonatomic,assign)NSInteger maxTime;
//是否转换amr格式
@property (nonatomic,assign)BOOL switchAmr;
@property (nonatomic,assign)id<recordVDelegate> delegate;
@end
