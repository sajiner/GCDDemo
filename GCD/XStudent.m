
//
//  XStudent.m
//  GCD
//
//  Created by 张鑫 on 2017/6/23.
//  Copyright © 2017年 张鑫. All rights reserved.
//

#import "XStudent.h"

@implementation XStudent

// 单例
+ (instancetype)sharedSingleton {
    
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSObject alloc] init];
    });
    return instance;
}

+ (instancetype)sharedSync {
    static id instance;
    @synchronized (self) {
        if (!instance) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

@end
