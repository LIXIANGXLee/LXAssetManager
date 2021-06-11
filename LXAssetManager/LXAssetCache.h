//
//  LXAssetCache.h
//  LXAssetManager
//
//  Created by 李响 on 2021/6/11.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/SDWebImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXAssetCache : NSObject
@property(nonatomic, strong)SDMemoryCache *memoryCache;

/// 单例模式
+ (instancetype)shared;

/// 设置最大缓存图片数量
- (void)setMaxCacheCount:(NSUInteger)maxCount;

/// 设置最大缓存空间大小, 单位 M
- (void)setMaxCacheSize:(NSUInteger)maxSize;

@end

NS_ASSUME_NONNULL_END
