//
//  LXAssetManager.h
//  LXAssetManager
//
//  Created by 李响 on 2020/3/9.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "LXAssetThread.h"

NS_ASSUME_NONNULL_BEGIN

@class LXAssetCollection;
@interface LXAssetManager : NSObject

/// 常驻线程
@property(nonatomic, strong)LXAssetThread *assetThread;

/// 单例模式
+ (instancetype)shared;

/// 获取所有相册 （必须先调用reloadAllAssetCollections加载数据，才能获取到数据，也是数据的优化）
- (void)fetchAllAssetCollections:(void(^)(NSArray<LXAssetCollection *> *assetCollections))completionHandler;

/// 重新加载所有相册 types == nil 默认是系统相册和自定义相册
- (void)reloadAllAssetCollections:(NSArray<NSNumber *> * _Nullable)types;

/// 清除相册
- (void)clearAllCollections;

@end

NS_ASSUME_NONNULL_END
