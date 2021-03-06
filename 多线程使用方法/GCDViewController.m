//
//  GCDViewController.m
//  多线程使用方法
//
//  Created by DYM on 16/6/26.
//  Copyright © 2016年 龙少. All rights reserved.
//

#import "GCDViewController.h"

@interface GCDViewController ()
{
     UIImageView *_iconImage;
}
@end

@implementation GCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _iconImage = [[UIImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:_iconImage];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self mergeImage];
}
#warning -------- 合并两张图片
- (void)mergeImage{
    
    //队列组
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //使用队列组下载图片
    __block UIImage *image1 = nil;
    dispatch_group_async(group, queue, ^{
        image1 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://ww2.sinaimg.cn/large/5de69ad1jw1evh5fihaxqj21jk0yqwxl.jpg"]]];
    });
    __block UIImage *image2 = nil;
    dispatch_group_async(group, queue, ^{
        //下载图片
        image2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://pic8.nipic.com/20100705/636809_145722082776_2.jpg"]]];
    });
    
    //队列组的任务都执行结束后 调用此方法
    dispatch_group_notify(group, queue, ^{
        //2.合并图片
        //2.1 开启上下文
        UIGraphicsBeginImageContextWithOptions(image1.size, NO, 0.0);
        //2.2 绘制图片
        [image1 drawAsPatternInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
        [image2 drawAsPatternInRect:CGRectMake(100,image1.size.height - 200, image2.size.width, 180)];
        //2.3 得到上下文的图片
        UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
        //2.4 结束上下文
        UIGraphicsEndImageContext();
        
        //3.返回主线程显示图片
        dispatch_async(dispatch_get_main_queue(), ^{
            _iconImage.image = fullImage;
        });
    });
}

#warning  --- GCD 代码只执行一次
- (void)GCDOne{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"改代码只会实行一次");
    });
}

#warning  --- GCD 延时调用 不会卡主线程
- (void)gcdTimeDelay{
    NSLog(@"-----began------");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //也可以放在子线程执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), queue, ^{
        NSLog(@"------ download -------");
    });
    NSLog(@"-----end------");

}

- (void)TimeDelay{
     NSLog(@"-----began------");
    [self performSelector:@selector(download:) withObject:@"http://a.jpg" afterDelay:3];
     NSLog(@"-----end------");
}

- (void)download:(NSString*)url{
    NSLog(@"%@------download",url);
}

#warning  ----------  GCD 线程之间的通信
- (void)asyncCommunication{
    //获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //获取主队列
    dispatch_queue_t queueMain = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        NSString *imgUrl = @"http://img.sootuu.com/vector/200801/072/0337.jpg";
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]]];
        
        //回到主线程设置照片
        dispatch_async(queueMain, ^{
            _iconImage.image = image;
        });
    });
}

#warning  ----------  GCD 使用方法
//异步 -- 主队列中执行（主队列是串行）
- (void)asynvMainQueue{
    //获取主队列 （添加到主队列的任务，都会放在主线程中执行）
    dispatch_queue_t queue = dispatch_get_main_queue();
    //将任务添加到队列中,异步 执行
    dispatch_async(queue, ^{
        NSLog(@"------下载图片1------%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"------下载图片2------%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"------下载图片3------%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"------下载图片4------%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"------下载图片5------%@", [NSThread currentThread]);
    });

}

//同步 -- 并发队列
- (void)syncGlobalQueue{
    //获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //将任务添加到队列中,同步执行
    dispatch_sync(queue, ^{
        NSLog(@"------下载图片1------%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"------下载图片2------%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"------下载图片3------%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"------下载图片4------%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"------下载图片5------%@", [NSThread currentThread]);
    });
}

//同步 -- 串行队列
- (void)syncSerialQueue{
    //创建一个串行队列
    dispatch_queue_t queue = dispatch_queue_create("队列名称", NULL);
    //将任务添加到队列中,同步执行
    dispatch_sync(queue, ^{
        NSLog(@"------下载图片1------%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"------下载图片2------%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"------下载图片3------%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"------下载图片4------%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"------下载图片5------%@", [NSThread currentThread]);
    });
}

// 异步-并发队列
- (void)asyncGlobalQueue{
    //获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //将任务添加到队列中,异步执行
    dispatch_async(queue, ^{
        NSLog(@"------下载图片1------%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"------下载图片2------%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"------下载图片3------%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"------下载图片4------%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"------下载图片5------%@", [NSThread currentThread]);
    });
}

//异步 -- 串行队列
- (void)asyncSerialQueue{
    //创建一个串行队列
    dispatch_queue_t queue = dispatch_queue_create("队列名称", NULL);
    //将任务添加到队列中,异步执行
    dispatch_async(queue, ^{
        NSLog(@"------下载图片1------%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"------下载图片2------%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"------下载图片3------%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"------下载图片4------%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"------下载图片5------%@", [NSThread currentThread]);
    });
}


/*
dispatch_async :异步，具有开辟线程的能力
dispatch_sync  :同步，不具有开辟线程的能力
 
并发队列：多个任务同时执行
串行队列：一个任务执行完之后，再执行下一个任务
 
是否开辟新的线程只取决于是 同步函数 还是 异步函数
 
//获取全局并发队列
   dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
 
//GCD 延时调用download:方法  不会卡主线程
     1.[self performSelector:@selector(download:) withObject:@"http://a.jpg" afterDelay:3];
     2.dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"------ download -------");
       });

//队列组
    dispatch_group_t group = dispatch_group_create();
//使用队列组创建任务
    dispatch_group_async(group, queue, ^{
       image1 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://ww2.sinaimg.cn/large/5de69ad1jw1evh5fihaxqj21jk0yqwxl.jpg"]]];
    });
//队列组的任务都执行结束后 调用此方法
    dispatch_group_notify(group, queue, ^{
 
   }
 
*/

@end
