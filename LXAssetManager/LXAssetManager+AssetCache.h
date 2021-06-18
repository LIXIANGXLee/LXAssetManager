//
//  LXAssetManager+AssetCache.h
//  LXAssetManager
//
//  Created by 李响 on 2021/6/18.
//

#import <LXAssetManager/LXAssetManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXAssetManager (AssetCache)

/// 设置最大缓存图片数量
- (void)setMaxCacheCount:(NSUInteger)maxCount;

/// 设置最大缓存空间大小, 单位 M
- (void)setMaxCacheSize:(NSUInteger)maxSize;

/// 默认设置
- (void)setDefault;

@end

NS_ASSUME_NONNULL_END
