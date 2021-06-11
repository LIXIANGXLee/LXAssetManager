//
//  LXAssetManager.h
//  LXAssetManager
//
//  Created by 李响 on 2020/3/9.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "LXAssetThread.h"

#define LXWeakObj(o) try{}@finally{} __weak typeof(o) o##Weak = o;
#define LXStrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

NS_ASSUME_NONNULL_BEGIN

@class LXAssetCollection;
@interface LXAssetManager : NSObject

/// 线程
@property(nonatomic, strong)LXAssetThread *assetThread;

/// 单例模式
+ (instancetype)shared;

/// 获取所有相册
- (void)fetchAllAssetCollections:(void(^)(NSArray<LXAssetCollection *> *assetCollections))completionHandler;

/// 重新加载所有相册
- (void)reloadAllAssetCollections:(NSArray<NSNumber *> * _Nullable)types;

/// 清除相册
- (void)clearAllCollections;

@end

NS_ASSUME_NONNULL_END
