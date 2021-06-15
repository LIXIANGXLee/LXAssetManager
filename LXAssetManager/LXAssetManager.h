//
//  LXAssetManager.h
//  LXAssetManager
//
//  Created by 李响 on 2020/3/9.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@class LXAssetCollection, LXAssetItem;
@interface LXAssetManager : NSObject

/// 单例模式
+ (instancetype)shared;

/// 重新加载所有相册 types == nil 默认是系统相册和自定义相册
///  @[@(PHAssetCollectionTypeSmartAlbum), @(PHAssetCollectionTypeAlbum)];
- (void)reloadAllAssetCollections:(NSArray<NSNumber *> * _Nullable)types;

/// 获取所有相册 （必须先调用reloadAllAssetCollections加载数据，才能获取到数据，也是数据的优化）
- (void)fetchAllAssetCollections:(void(^)(NSArray<LXAssetCollection *> *assetCollections))completionHandler;

/// 获取最近项目相册
- (void)fetchRecentsAssetCollection:(void(^)(LXAssetCollection * assetCollection))completionHandler;

/// 获取最近项目相册里的所有资源
- (void)fetchRecentsAssetItems:(void(^)(NSArray<LXAssetItem *> * _Nullable assetItems))completionHandler;

/// 清除相册
- (void)clearAllCollections;

@end

NS_ASSUME_NONNULL_END
