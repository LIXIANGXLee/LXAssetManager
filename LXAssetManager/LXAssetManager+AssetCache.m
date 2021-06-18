//
//  LXAssetManager+AssetCache.m
//  LXAssetManager
//
//  Created by 李响 on 2021/6/18.
//

#import "LXAssetManager+AssetCache.h"

@implementation LXAssetManager (AssetCache)

- (void)setMaxCacheCount:(NSUInteger)maxCount {
    self.memoryCache.config.maxMemoryCount = maxCount;
}

- (void)setMaxCacheSize:(NSUInteger)maxSize {
    self.memoryCache.config.maxMemoryCost = maxSize*1024*1024;
}

- (void)setDefault {
    [self setMaxCacheSize:15];
    [self setMaxCacheCount:50];
}

@end
