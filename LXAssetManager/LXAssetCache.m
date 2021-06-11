//
//  LXAssetCache.m
//  LXAssetManager
//
//  Created by 李响 on 2021/6/11.
//

#import "LXAssetCache.h"

@implementation LXAssetCache

+ (instancetype)shared {
    static LXAssetCache *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.memoryCache = [[SDMemoryCache alloc] init];
        [self setMaxCacheSize:15];
        [self setMaxCacheCount:50];
    }
    return self;
}

- (void)setMaxCacheCount:(NSUInteger)maxCount {
    self.memoryCache.config.maxMemoryCount = maxCount;
}

- (void)setMaxCacheSize:(NSUInteger)maxSize {
    self.memoryCache.config.maxMemoryCost = maxSize*1024*1024;
}

@end
