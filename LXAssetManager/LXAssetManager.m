//
//  LXAssetManager.m
//  LXAssetManager
//
//  Created by 李响 on 2020/3/9.
//

#import "LXAssetManager.h"
#import "LXAssetCollection.h"
#import "LXAssetCache.h"

@interface LXAssetManager()
@property (nonatomic, strong)NSMutableArray<LXAssetCollection *> *assetCollections;
@property(nonatomic, strong)NSArray *types;
@end

@implementation LXAssetManager

+ (instancetype)shared {
    static LXAssetManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.types = @[@(PHAssetCollectionTypeSmartAlbum),
                       @(PHAssetCollectionTypeAlbum)];

        self.assetThread = [[LXAssetThread alloc] init];
    }
    return self;
}

- (void)fetchAllAssetCollections:(void (^)(NSArray<LXAssetCollection *> * _Nonnull))completionHandler {
    
    @LXWeakObj(self);
    [self.assetThread executeTask:^{
    @LXStrongObj(self);
      dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) {
                completionHandler(self.assetCollections);
            }
        });
    }];
}

- (void)reloadAllAssetCollections:(NSArray<NSNumber *> *)types{
    if (!types || types.count == 0) {
        types = self.types;
    }
    @LXWeakObj(self);
    [self.assetThread executeTask:^{
    @LXStrongObj(self);
        [self.assetCollections removeAllObjects];
        [types enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj,
                                            NSUInteger idx,
                                            BOOL * _Nonnull stop) {
            if ([self.types containsObject:obj]) {
                [self fetchCollectionWithType:obj.integerValue];
            }
        }];
    }];
}

- (void)clearAllCollections {
    @LXWeakObj(self);
    [self.assetThread executeTask:^{
    @LXStrongObj(self);
        [self.assetCollections removeAllObjects];
        [[LXAssetCache shared].memoryCache removeAllObjects];
    }];
}

/// 获取系统相册
-(NSArray<LXAssetCollection *> *)fetchCollectionWithType:(PHAssetCollectionType)type {
    
    PHFetchResult<PHAssetCollection *> *collections;
    collections = [PHAssetCollection fetchAssetCollectionsWithType:type
                                                           subtype:PHAssetCollectionSubtypeAny
                                                           options:nil];
    __weak typeof(self)weakSelf = self;
    [collections enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection,
                                              NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        LXAssetCollection *assetCollection = [strongSelf creatAssetCollectionFrom:collection];
        if (assetCollection && assetCollection.firstAssetItem) {
            if (collection.assetCollectionType == PHAssetCollectionTypeAlbum &&
                collection.assetCollectionSubtype == PHAssetCollectionSubtypeAlbumRegular) {
                assetCollection.title = collection.localizedTitle;
                [strongSelf.assetCollections addObject:assetCollection];
            }else{
                assetCollection.title = [self transformAblumTitle:collection.localizedTitle];
                if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary ||
                    collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded) {
                    [weakSelf.assetCollections insertObject:assetCollection atIndex:0];
                }else{
                    [strongSelf.assetCollections addObject:assetCollection];
                }
            }
        }
    }];
    return self.assetCollections;
}

- (LXAssetCollection * _Nullable)creatAssetCollectionFrom:(PHAssetCollection *)aCollection  {
    
    if (![self checkValidFor:aCollection]) {
        return nil;
    }
    
    LXAssetCollection *assetCollection = [[LXAssetCollection alloc] init];
    assetCollection.assetCollection = aCollection;
    return assetCollection;
}

- (BOOL)checkValidFor:(PHAssetCollection *)assetCollection {
    if (![assetCollection isKindOfClass:[PHAssetCollection class]] ||
        assetCollection.estimatedAssetCount <= 0 ||
        assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden ||
        assetCollection.assetCollectionSubtype == 215 ||
        assetCollection.assetCollectionSubtype == 212 ||
        assetCollection.assetCollectionSubtype == 204 ||
        assetCollection.assetCollectionSubtype == 1000000201) {
        return false;
    }
    return true;
}

- (NSString *)transformAblumTitle:(NSString *)title {
    if ([title isEqualToString:@"Slo-mo"]) {
        return @"慢动作";
    } else if ([title isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    } else if ([title isEqualToString:@"Panoramas"]) {
        return @"全景照片";
    } else if ([title isEqualToString:@"Panoramas"]) {
        return @"全景照片";
    } else if ([title isEqualToString:@"Favorites"]) {
        return @"个人收藏";
    } else if ([title isEqualToString:@"Time-lapse"]) {
        return @"延时摄影";
    } else if ([title isEqualToString:@"Live Photos"]) {
        return @"实况照片";
    } else if ([title isEqualToString:@"Animated"]) {
        return @"动图";
    } else if ([title isEqualToString:@"Bursts"]) {
        return @"连拍快照";
    } else if ([title isEqualToString:@"Portrait"]) {
        return @"肖像";
    } else if ([title isEqualToString:@"Ritratti"]) {
        return @"人像";
    }else if ([title isEqualToString:@"Long Exposure"]) {
        return @"长时间曝光";
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    } else if ([title isEqualToString:@"Videos"]) {
        return @"视频";
    } else if ([title isEqualToString:@"All Photos"]) {
        return @"所有照片";
    } else if ([title isEqualToString:@"Selfies"]) {
        return @"自拍";
    } else if ([title isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    } else if ([title isEqualToString:@"Recents"]) {
        return @"最近項目";
    }else if ([title isEqualToString:@"My Photo Stream"]){
        return @"我的照片流";
    }
    return nil;
}

- (NSMutableArray<LXAssetCollection *> *)assetCollections {
    if (!_assetCollections) {
        _assetCollections = [NSMutableArray array];
    }
    return _assetCollections;
}

@end


