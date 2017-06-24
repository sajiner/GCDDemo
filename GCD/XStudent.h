//
//  XStudent.h
//  GCD
//
//  Created by 张鑫 on 2017/6/23.
//  Copyright © 2017年 张鑫. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XStudent : NSObject

+ (instancetype)sharedSingleton;
+ (instancetype)sharedSync;

@end
