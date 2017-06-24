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
    [self dependency];
}

/// 依赖关系
- (void)dependency {
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"登录 %@", [NSThread currentThread]);
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"付费 %@", [NSThread currentThread]);
    }];
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"下载 %@", [NSThread currentThread]);
    }];
    NSBlockOperation *op4 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"通知用户 %@", [NSThread currentThread]);
    }];
    
    [op2 addDependency:op1];
    [op3 addDependency:op2];
    [op4 addDependency:op3];
    // YES - 同步； NO - 异步
    [self.queue addOperations:@[op1, op2, op3] waitUntilFinished:YES];
    [[NSOperationQueue mainQueue] addOperation:op4];
    NSLog(@"come here");
}

/// 暂停／继续
/// 队列挂起，当前‘没有完成的操作’，是算在队列的操作数里的
/// 队列挂起，不会影响已经执行操作的执行状态
/// 对列一旦被挂起，再添加的操作不会被调度
- (IBAction)pauseAndResume {
    if (self.queue.operationCount == 0) {
        return;
    }
    self.queue.suspended = !self.queue.isSuspended;
    if (self.queue.isSuspended) {
        NSLog(@"暂停%tu", self.queue.operationCount);
    } else {
        NSLog(@"继续%tu", self.queue.operationCount);
    }
}

/// 取消队列中的所有操作
/// 不会取消正在执行中的操作
/// 不会影响队列的挂起状态
- (IBAction)cancelAll {
    if (self.queue.operationCount == 0) {
        return;
    }
    
    [self.queue cancelAllOperations];
    NSLog(@"取消全部操作：%tu", self.queue.operationCount);
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
