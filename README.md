# soundRecord
一个简单的ios录音器，支持专程amr，代码简单

使用方法
    
    recordV *reee = [[recordV alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-300)*0.5, [UIScreen mainScreen].bounds.size.height - 200, 100, 50)];
    
    reee.delegate = self;
    
    reee.maxTime = 10;
    reee.switchAmr = YES;
    reee.backgroundColor = [UIColor redColor];
    [self.view addSubview:reee];
    
    #pragma mark - 录音代理
    //录音成功，返回路径和录音时间
    -(void)recordSuccess:(recordV *)recordV withFile:(NSString *)file soundTime:(int)soundTime
    {
    }
    //录音失败，返回错误代码
    - (void)recordFail:(recordV *)recordV withError:(soundRecordtype)Error
    {
    }

期待



