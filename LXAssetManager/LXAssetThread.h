//
//  LXAssetThread.h
//  LXAssetManager
//
//  Created by Mac on 2020/9/26.
//  Copyright © 2020 李响. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^LXAssetThreadTask)(void);

@interface LXAssetThread : NSObject

///开启线程
- (void)start;

/// 在线程执行任务
- (void)executeTask:(LXAssetThreadTask)task;

///结束线程
- (void)stop;

@end

NS_ASSUME_NONNULL_END
