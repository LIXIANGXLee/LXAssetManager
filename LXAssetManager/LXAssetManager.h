//
//  LXAssetManager.h
//  LXAssetManager
//
//  Created by 李响 on 2020/3/9.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@class LXAssetCollection;
@interface LXAssetManager : NSObject

/// 单例模式
+ (instancetype)shared;

/// 获取所有相册
- (void)fetchAllAssetCollections:(void(^)(NSArray<LXAssetCollection *> *assetCollections))completionHandler;

/// 重新加载所有相册
- (void)reloadAllAssetCollections:(NSArray<NSNumber *> *)types;

/// 清除相册
- (void)clearAllCollections;

@end

NS_ASSUME_NONNULL_END
