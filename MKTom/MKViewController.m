//
//  MKViewController.m
//  MKTom
//
//  Created by Mkil on 11/28/15.
//  Copyright (c) 2015 Mkil. All rights reserved.
//

#import "MKViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MKViewController () <AVAudioPlayerDelegate>
{
    NSDictionary *_dict;  //保存所以图片的个数
    NSDictionary *_soundDic; //保存声音的个数
    //设置播放音频的对象指针为全局变量（或者也可以设置为局部的static静态变量）总之player
    //的生命周期得是全局，如果是局部变量的话，代码块执行完，player也被释放了，音频也就播放不了；
    AVAudioPlayer *_player;
    
    NSString *_delegateSoundName; //循环播放连续多个音频文件时下个音频的文件名
    
    NSInteger _soundCount; // 循环播放连续多个音频文件时的次数 
}

@end

@implementation MKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //-------1.获得tomAnimations.plist的全路径
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"tomAnimations" ofType:@"plist"];
    
    //-------2.根据文件路径加载图片字典
    
    _dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    //-------3.获得tomSounds.plist的路径
    
    path = [[NSBundle mainBundle] pathForResource:@"tomSounds" ofType:@"plist"];
    
    //-------4.根据路径加载声音字典
    
    _soundDic = [NSDictionary dictionaryWithContentsOfFile:path];
    
    
//----------手动布局
    //------创建UIImageView
    
    _tom = [[UIImageView alloc] init];
    
    _tom.frame = self.view.frame; //使ImageView充满整个视图
    _tom.contentMode = UIViewContentModeScaleAspectFill;//填充模式，可能存在压缩/拉伸， 图片可能变形, 默认
    
    path = [[NSBundle mainBundle] pathForResource:@"cat_angry0000.jpg" ofType:nil];
    
    // 加载图片(缓存)
    //        UIImage *img = [UIImage imageNamed:name];
    // 没有缓存
    
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];    //添加图片
    
    _tom.image = img;
    
    //显示在MKView上
    
    [self.view addSubview:_tom];
    
//---------创建Button
    //获得tomButton.plist 的全路径
    
    path = [[NSBundle mainBundle] pathForResource:@"tomButton" ofType:@"plist"];
    //根据path加载Array
    
    NSArray *buttonArray = [NSArray arrayWithContentsOfFile:path];
    //for循环创建并设置Button
    
    for (NSInteger i = 0; i < 3; i ++) {
        for (NSInteger j = 0; j < 2; j ++) {
            //设置Button 样式
            //圆角矩形          7.0废弃， 等同于系统类型
            //UIButtonTypeRoundedRect = UIButtonTypeSystem,
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            //设置Button的位置
            
            button.frame = CGRectMake(15 + j * (self.view.frame.size.width - 110), 390 + i * 80, 80, 80);
            //设置Button在UIControlStateNormal下的Title
            
            [button setTitle:buttonArray[i*2 + j] forState:UIControlStateNormal];
            //设置Button 的 tint颜色为透明色 :默认为蓝色
            
            button.tintColor = [UIColor clearColor];
            
            //获得Button背景图片的路径
            
            path = [[NSBundle mainBundle] pathForResource:buttonArray[i*2+j] ofType:@"png"];
            //通过路径获得背景图片
            
            UIImage *buttonImage = [[UIImage alloc] initWithContentsOfFile:path];
            
            //一般状态下的背景图片
            
            [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
            //设置 tag值,从1 开始
            
            button.tag = i + 1;
            
            //设置代理
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            //显示
            [self.view addSubview:button];
        }
    }
    //创建并设置隐藏的Button
    for (NSInteger i = 0; i < 4 ; i ++) {
        //创建Button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //设置Button在UIControlStateNormal下的Title
        
        [button setTitle:buttonArray[i+6] forState:UIControlStateNormal];
        //设置Button 的 tint颜色为透明色 :默认为蓝色
        
        button.tintColor = [UIColor clearColor];
        
       
        
        switch (i) {
            case 0:
                button.frame = CGRectMake(70, 110, 230, 230);
                break;
            case 1:
                button.frame = CGRectMake(125, 380, 130, 130);
                break;
            case 2:
                button.frame = CGRectMake(110, 520, 70, 60);
                break;
            case 3:
                button.frame = CGRectMake(200, 520, 70, 60);
                break;
            default:
                break;
        }
        //设置tag
        button.tag = i+6+1;
        
        //设置代理
        
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        //显示
        [self.view addSubview:button];
        
    }
    
    
    
}

- (void)playAnimations:(NSString *)fileName imagecount:(NSInteger )imagecount soundCount:(NSInteger ) soundcount
{
    // 创建UIImage 的可变数组
    
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    
    //获得file的所有图片
    
    for (NSInteger i = 0; i < imagecount; i ++) {
        
        NSString * path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"cat_%@00%02ld",fileName,i] ofType:@"jpg"];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
        
        [imageArray addObject:image];
    }
    
    //设置播放图片的数组
    _tom.animationImages = imageArray;
    
    //设置播放时间
    _tom.animationDuration = 0.1 * imagecount;
    
    //设置播放次数:一次
    _tom.animationRepeatCount = 1;
    
    //开始播放动画
    
    [_tom startAnimating];
    
    
}

- (void)playerSound:(NSString *)fileName
{

    //播放音频， AVPlayer 用来播放音频的类
    //
    
    //设置会话类型
    AVAudioSession *session=[AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [session setActive:YES error:nil];
    
    //  需要连续播放的音频进入if 否 else
    if ([fileName isEqualToString:@"drink"] || [fileName isEqualToString:@"knockout"]) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@0%02d",fileName,0] ofType:@"wav"];
        
        NSURL *url = [NSURL fileURLWithPath:path];
        
        
        
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        
        [_player prepareToPlay]; //分配播放所需的资源，并将其加入内部播放队列
        [_player play];             //播放
        _soundCount = 1; //下一个音频文件的编号
        
        //文件名
        _delegateSoundName = fileName;
        
        //为连续播放的音频设置代理：遵守<AVAudioPlayerDelegate>协议
        _player.delegate = self;
    }else{
        if ([fileName hasPrefix:@"foot"]) {
            fileName = [fileName substringToIndex:4];
        }
        NSInteger num;
        if ([_soundDic[fileName] integerValue] > 1) {
             num = arc4random() % [_soundDic[fileName] integerValue];
        }else{
            num = 0;
        }
        
        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@0%02ld",fileName,num] ofType:@"wav"];
        
        NSURL *url = [NSURL fileURLWithPath:path];
        
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        
        [_player prepareToPlay];  //分配播放所需的资源，并将其加入内部播放队列
        [_player play]; //播放
        
    }

    
}

//播放结束时调用
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"%ld",_soundCount);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@0%02ld",_delegateSoundName,_soundCount] ofType:@"wav"];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSLog(@"%ld %@ %ld",_soundCount,path,[_soundDic[_delegateSoundName] integerValue]);
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    
    if (++_soundCount < [_soundDic[_delegateSoundName] integerValue]) {
        
        //监控剩下的音频文件
        _player.delegate = self;
    }
    
    [_player prepareToPlay];
    [_player play];
    
}

#pragma mark - 监听所有的按钮点击
- (void)buttonClicked:(UIButton *)sender
{
    // 1.如果tom正在播放动画，直接返回
    if (_tom.isAnimating) return;
    
    //取出按钮文字
    NSString *fileName = [sender titleForState:UIControlStateNormal];
    
    //获得图片数量
    
    NSInteger imagecount = [_dict[fileName] integerValue];
    NSInteger soundcount = [_soundDic[fileName] integerValue];
    
    NSLog(@"%@ %ld",fileName,imagecount);
    
    //播放动画
    
    [self playAnimations:fileName imagecount:imagecount soundCount:soundcount];
    
    //播放音频
    
    [self playerSound:fileName];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
