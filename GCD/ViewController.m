//
//  ViewController.m
//  GCD
//
//  Created by 张鑫 on 2017/6/11.
//  Copyright © 2017年 张鑫. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self gcdDemo4];
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
