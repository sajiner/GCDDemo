//
//  ViewController.m
//  GCD
//
//  Created by 张鑫 on 2017/6/11.
//  Copyright © 2017年 张鑫. All rights reserved.
//

#import "ViewController.h"
#import "XStudent.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"测试分支");
    NSLog(@"coem here");
}

- (void)loadView {
    [super loadView];
//    
//    UITableView *tableView = [[UITableView alloc] init];
//    self.view = tableView;
}


/**
 GCD 
    三要素：队列、任务和函数
    队列：串行队列、并行队列
 
    * 开不开线程由执行任务的函数决定 ：异步开，同步不开
    * 开几条线程由队列决定：串行开一条，并行开多条
 
    * 如果主线程上正在有代码执行，就不会调度队列中的任务
 

 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self loginDemo];
}

- (void)loginDemo1 {
    dispatch_queue_t q = dispatch_queue_create("jah", DISPATCH_QUEUE_CONCURRENT);
    void(^task)() = ^{
        dispatch_sync(q, ^{
            NSLog(@"login: %@", [NSThread currentThread]);
        });
        dispatch_async(q, ^{
            NSLog(@"download A: %@", [NSThread currentThread]);
        });
        dispatch_async(q, ^{
            NSLog(@"download B: %@", [NSThread currentThread]);
        });
    };
    dispatch_async(q, task);
}

- (void)loginDemo {
    dispatch_queue_t q = dispatch_queue_create("jah", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(q, ^{
        NSLog(@"login: %@", [NSThread currentThread]);
    });
    dispatch_async(q, ^{
        NSLog(@"download A: %@", [NSThread currentThread]);
    });
    dispatch_async(q, ^{
        NSLog(@"download B: %@", [NSThread currentThread]);
    });
}


- (void)group {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t q = dispatch_get_global_queue(0, 0);
    dispatch_group_async(group, q, ^{
        NSLog(@"任务1 ： %@", [NSThread currentThread]);
    });
    dispatch_group_async(group, q, ^{
        NSLog(@"任务2 ： %@", [NSThread currentThread]);
    });
    dispatch_group_async(group, q, ^{
        NSLog(@"任务3 ： %@", [NSThread currentThread]);
    });
    
    dispatch_group_notify(group, q, ^{
        NSLog(@"over: %@", [NSThread currentThread]);
    });
    
    NSLog(@"come here");
}

- (void)onceDemo1 {
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    for (int i = 0; i < 10; i++) {
        NSLog(@"%p", [XStudent sharedSync]);
    }
    NSLog(@"互斥锁 -- %f", CFAbsoluteTimeGetCurrent() - time);
    
    
    
    time = CFAbsoluteTimeGetCurrent();
    for (int i = 0; i < 10; i++) {
        NSLog(@"%p", [XStudent sharedSingleton]);
    }
    NSLog(@"dispatch_once -- %f", CFAbsoluteTimeGetCurrent() - time);
}

- (void)onceDemo {
    for (int i = 0; i < 10; i++) {
        [self once];
    }
}

- (void)once {
    static dispatch_once_t onceToken;
    // 0-执行dispatch_once  -1-不执行
    // dispatch_once 内部也有一把锁，可以保证线程安全
    NSLog(@"%ld", onceToken);
    dispatch_once(&onceToken, ^{
        NSLog(@"是一次操作吗");
    });
    NSLog(@"come here");
}

- (void)delayDemo {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"come here");
    });
}

// 全局队列 异步执行
// 开一条线程，顺序执行，come here最前边
- (void)gcdDemo11 {
    dispatch_queue_t q = dispatch_get_global_queue(0, 0);
    
    for (int i = 0; i < 10; i++) {
        dispatch_async(q, ^{
            NSLog(@"%d -- %@", i, [NSThread currentThread]);
        });
    }
    NSLog(@"come here");
}

// 主队列 异步执行
// 开一条线程，顺序执行，come here最前边
- (void)gcdDemo10 {
    dispatch_queue_t q = dispatch_get_main_queue();
    for (int i = 0; i < 10; i++) {
        dispatch_async(q, ^{
            NSLog(@"%d -- %@", i, [NSThread currentThread]);
        });
    }
    NSLog(@"come here");
}

// 主队列 同步执行
// 死循环
- (void)gcdDemo5 {
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"%@", [NSThread currentThread]);
    });
    NSLog(@"come here");
}

// 并行队列 异步执行
// 开多条线程、乱序执行，come here随意
- (void)gcdDemo9 {
    dispatch_queue_t queue = dispatch_queue_create("hah", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"%d -- %@", i, [NSThread currentThread]);
        });
    }
    NSLog(@"come here");
}


// 并行队列 同步执行
// 不开线程、顺序执行，come here在最后
- (void)gcdDemo8 {
    dispatch_queue_t queue = dispatch_queue_create("hah", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 10; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"%d -- %@", i, [NSThread currentThread]);
        });
    }
    NSLog(@"come here");
}


// 串行队列 异步执行
// 开1条线程、顺序执行，come here随意
- (void)gcdDemo7 {
    dispatch_queue_t queue = dispatch_queue_create("hah", DISPATCH_QUEUE_SERIAL);
    for (int i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"%d -- %@", i, [NSThread currentThread]);
        });
    }
    NSLog(@"come here");
}


// 串行队列 同步执行
// 不开线程、顺序执行，come here在最后
- (void)gcdDemo6 {
    dispatch_queue_t queue = dispatch_queue_create("hah", DISPATCH_QUEUE_SERIAL);
    for (int i = 0; i < 10; i++) {
        NSLog(@"%d", i);
        dispatch_sync(queue, ^{
            NSLog(@"%@", [NSThread currentThread]);
        });
    }
    NSLog(@"come here");
}


- (void)gcdDemo4 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"耗时操作 - %@", [NSThread currentThread]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"更新UI - %@", [NSThread currentThread]);
        });
    });
}

- (void)gcdDemo3 {
    for (int i = 0; i < 10; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"%@", [NSThread currentThread]);
        });
    }
}

- (void)gcdDemo2 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"%@", [NSThread currentThread]);
    });
}

- (void)gcdDemo1 {
    dispatch_queue_t q = dispatch_get_global_queue(0, 0);
    void (^task)() = ^{
        NSLog(@"%@", [NSThread currentThread]);
    };
    
    dispatch_async(q, task);
}

@end
