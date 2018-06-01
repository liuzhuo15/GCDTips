//
//  ViewController.m
//  GCDTips
//
//  Created by Zhuo Liu on 2018/5/23.
//  Copyright © 2018年 Zhuo Liu. All rights reserved.
//
/**
1、GCD的优点
 * GCD可用于多核的并行运算
 * GCD会自动利用更多的CPU内核（如双核、四核）
 * GCD会自动管理线程的生命周期：创建线程、调度任务、销毁线程
 *
 *dd
2、GCD的核心概念：任务和队列
 * 任务：就是执行操作的意思，即在线程中执行的那段代码。在GCD中是放在block里面的。
 * 执行任务有两种方式：
 * 同步执行（sync）：添加任务到指定队列中，等待前面的任务完成之后再开始执行；不具备开启新线程的能力
 * 异步执行（async）：添加任务到指定队列中，不用等待就继续执行，具备开启新线程的能力（并不一定开启新的线程）
 
 * 队列：指的是执行任务的等待队列，即用来存放任务的队列。队列是一种特殊的线性表，采用FIFO（先进先出）原则
 * GCD中有两种队列：串行队列和并行队列，主要区别在于执行顺序和开启线程数不同。
 * 串行队列（Serial Dispatch Queue）：每次只有一个任务被执行，任务一个接一个得执行，只开启一条线程
 * 并行队列（Concurrent Dispatch Queue）：可以多个任务并发执行，可开启多条线程（实质上是在快速来回切换执行的任务，一般说成是多个任务同时执行）
 * 并行队列的并发功能只有在异步（dispatch_async）函数下才会有效
 *
 *
3、GCD的使用步骤：1、创建队列；2、将待执行的任务追加到队列中
 *
 *
4、GCD的基本使用：
 * 同步执行+并发队列：没有开启新线程，串行执行任务
 * 异步执行+并发队列：有开启新线程，并发执行任务
 * 同步执行+串行队列：没有开启新线程，串行执行任务
 * 异步执行+串行队列：有开启新线程(1条)，串行执行任务
 * 同步执行+主队列：死锁卡住不执行
 * 异步执行+主队列：没有开启新线程，串行执行任务
 *
 */

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *titleArr = @[@"同步任务—并行队列",
                          @"异步任务-并行队列",
                          @"同步任务-串行队列",
                          @"异步任务-串行队列",
                          @"同步任务-主行队列",
                          @"异步任务-主行队列"];
    for (NSInteger i = 0; i < 6; i++) {
        CGRect frame = CGRectMake([UIScreen mainScreen].bounds.size.width*0.5-120, 100+60*i, 240, 44);
        [self.view addSubview:[self createBtnWithFrame:frame title:titleArr[i] tag:i]];
    }
}

- (UIButton *)createBtnWithFrame:(CGRect)frame title:(NSString *)title tag:(NSInteger)tag{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0
                                          green:arc4random_uniform(256)/255.0
                                           blue:arc4random_uniform(256)/255.0
                                          alpha:0.5];
    return btn;
}

- (void)btnClicked:(UIButton *)btn {
    switch (btn.tag) {
        case 0:
        {
            [self syncConcurrent];
        }
            break;
            
        case 1:
        {
            [self asyncConcurrent];
        }
            break;
            
        case 2:
        {
            [self syncSerial];
        }
            break;
            
        case 3:
        {
            [self asyncSerial];
        }
            break;
            
        case 4:
        {
            [self syncMainQueue];
        }
            break;
            
        case 5:
        {
            [self asyncMainQueue];
        }
            break;
            
        default:
            break;
    }
}

- (void)syncConcurrent {
    NSLog(@"syncConcurrent----------currentThread----------%@",[NSThread currentThread]);
    NSLog(@"syncConcurrent----------begin");
    dispatch_queue_t concurrentQueue = dispatch_queue_create("Liuxiaopang.GCDTips", DISPATCH_QUEUE_CONCURRENT);

    dispatch_sync(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"1---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"1---between---doing something---%@",[NSThread currentThread]);
    
    dispatch_sync(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"2---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"2---between---doing something---%@",[NSThread currentThread]);
    
    dispatch_sync(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"3---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"syncConcurrent----------end");
}

- (void)asyncConcurrent {
    NSLog(@"asyncConcurrent----------currentThread----------%@",[NSThread currentThread]);
    NSLog(@"asyncConcurrent----------begin");
    dispatch_queue_t concurrentQueue = dispatch_queue_create("Liuxiaopang.GCDTips", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"1---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"1---between---doing something---%@",[NSThread currentThread]);
    
    dispatch_async(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"2---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"2---between---doing something---%@",[NSThread currentThread]);
    
    dispatch_async(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"3---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"asyncConcurrent----------end");
}

- (void)syncSerial {
    NSLog(@"syncSerial----------currentThread----------%@",[NSThread currentThread]);
    NSLog(@"syncSerial----------begin");
    
    dispatch_queue_t serialQueue = dispatch_queue_create("Liuxiaopang.GCDTips", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(serialQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"1---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"1---between---doing something---%@",[NSThread currentThread]);
    
    dispatch_sync(serialQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"2---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"2---between---doing something---%@",[NSThread currentThread]);
    
    dispatch_sync(serialQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"3---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"syncSerial----------end");
}

- (void)asyncSerial {
    NSLog(@"asyncSerial----------currentThread----------%@",[NSThread currentThread]);
    NSLog(@"asyncSerial----------begin");
    
    dispatch_queue_t serialQueue = dispatch_queue_create("Liuxiaopang.GCDTips", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(serialQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"1---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"1---between---doing something---%@",[NSThread currentThread]);
    
    dispatch_async(serialQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"2---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"2---between---doing something---%@",[NSThread currentThread]);
    
    dispatch_async(serialQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"3---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"asyncSerial----------end");
}

- (void)syncMainQueue {
    NSLog(@"syncMainQueue----------currentThread----------%@",[NSThread currentThread]);
    NSLog(@"syncMainQueue----------begin");
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_sync(mainQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"1---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"1---between---doing something---%@",[NSThread currentThread]);
    
    dispatch_sync(mainQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"2---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"2---between---doing something---%@",[NSThread currentThread]);
    
    dispatch_sync(mainQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"3---doing something---%@",[NSThread currentThread]);
    });
    NSLog(@"syncMainQueue----------end");
}

- (void)asyncMainQueue {
    NSLog(@"asyncMainQueue----------currentThread----------%@",[NSThread currentThread]);
    NSLog(@"asyncMainQueue----------begin");
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();

    dispatch_async(mainQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"1---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"1---between---doing something---%@",[NSThread currentThread]);
    
    dispatch_async(mainQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"2---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"2---between---doing something---%@",[NSThread currentThread]);
    
    dispatch_async(mainQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"3---doing something---%@",[NSThread currentThread]);
    });
    
    NSLog(@"asyncMainQueue----------end");
}

- (void)getDispatchQueueTest {
    /**
     Description 创建串行队列
     "Liuxiaopang.GCDTips" 队列的唯一标志符，用于DEBUG，可为空
     DISPATCH_QUEUE_SERIAL 用于识别是串行还是并行
     */
    dispatch_queue_t serialQueue = dispatch_queue_create("Liuxiaopang.GCDTips", DISPATCH_QUEUE_SERIAL);
    NSLog(@"%@",serialQueue);
    
    /**
     Description 创建并行队列
     "Liuxiaopang.GCDTips" 队列的唯一标志符，用于DEBUG，可为空
     DISPATCH_QUEUE_SERIAL 用于识别是串行还是并行
     */
    dispatch_queue_t concurrentQueue = dispatch_queue_create("Liuxiaopang.GCDTips", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"%@",concurrentQueue);
    
    /**
     Description 获取主队列————特殊的串行队列
     */
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    NSLog(@"%@",mainQueue);
    
    /**
     Description 获取全局并发队列————特殊的并行队列
     DISPATCH_QUEUE_PRIORITY_DEFAULT 队列优先级
     0 暂时未用到的参数，为以后备用
     */
    dispatch_queue_t gloabalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"%@",gloabalQueue);
}

@end
