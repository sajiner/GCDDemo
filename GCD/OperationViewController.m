//
//  OperationViewController.m
//  GCD
//
//  Created by 张鑫 on 2017/6/24.
//  Copyright © 2017年 张鑫. All rights reserved.
//

#import "OperationViewController.h"

@interface OperationViewController ()

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation OperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self opDemo8];
}


/// 最大并发数:
/// 最大并发数：是同一时间开启线程的个数，并不是指一共开启线程的总数
- (void)opDemo8 {
    self.queue.maxConcurrentOperationCount = 3;
    for (int i = 0; i < 10; i++) {
        [self.queue addOperationWithBlock:^{
            [NSThread sleepForTimeInterval:2];
            NSLog(@"%@ -- %d", [NSThread currentThread], i);
        }];
    }
}

/// 线程间通讯
- (void)opDemo7 {
    [self.queue addOperationWithBlock:^{
        NSLog(@"耗时操作：%@", [NSThread currentThread]);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"更新UI：%@", [NSThread currentThread]);
        }];
    }];
}

/// 可以向 NSOperationQueue 中添加任意 NSOperation 的子类
- (void)opDemo6 {
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"NSBlockOperation: %@", [NSThread currentThread]);
    }];
    [self.queue addOperation:blockOp];
    
    for (int i = 0; i < 10; i++) {
        [self.queue addOperationWithBlock:^{
            NSLog(@"%@ -- %d", [NSThread currentThread], i);
        }];
    }
    
    NSInvocationOperation *invocationOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:@"invocarion"];
    [self.queue addOperation:invocationOp];
}

/// 更简洁的写法
- (void)opDemo5 {
    for (int i = 0; i < 10; i++) {
        [self.queue addOperationWithBlock:^{
            NSLog(@"%@ -- %d", [NSThread currentThread], i);
        }];
    }
}

/// NSBlockOperation
- (void)opDemo4 {
    for (int i = 0; i < 10; i++) {
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"%@ -- %d", [NSThread currentThread], i);
        }];
        [self.queue addOperation:op];
    }
}

/*
  由1～3 demo 可知：
  队列 - 全局队列
  操作 - 异步执行的任务
 */

/// 会开启多条线程，且乱序执行
- (void)opDemo3 {
    for (int i = 0; i < 10; i++) {
        NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:@(i)];
        [self.queue addOperation:op];
    }
}

- (void)opDemo2 {
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:@"invocation"];
    // 将‘操作’添加到队列，会‘异步’执行selector 方法
    [self.queue addOperation:op];
}

/// NSInvocationOperation
- (void)opDemo1 {
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:@"invocation"];
    // start 方法会在当前线程执行
    [op start];
}

- (void)downloadImage: (id)obj {
    NSLog(@"%@ -- %@", [NSThread currentThread], obj);
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

@end
