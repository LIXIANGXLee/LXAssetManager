//
//  LXAssetManager.m
//  LXAssetManager
//
//  Created by 李响 on 2020/3/9.
//

#import "LXAssetManager.h"
#import "LXAssetCollection.h"
#import "LXAssetCache.h"
#import "LXAuthorManager.h"
#import "LXAssetDefine.h"

@interface LXAssetManager()

@property(nonatomic, strong)dispatch_queue_t  fetchQueue;
@property (nonatomic, strong)NSMutableArray<LXAssetCollection *> *assetCollections;
@property (nonatomic, strong)NSArray *types;
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

        self.fetchQueue = dispatch_queue_create("LXASSETMANAGER_QUEUE", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)fetchAllAssetCollections:(void (^)(NSArray<LXAssetCollection *> * _Nonnull))completionHandler {
    ASYNC_THREAD(
      if (completionHandler) {
        ASYNC_MAINTHREAD(
            completionHandler(self.assetCollections);
        )
      }
    )
}

- (void)fetchRecentsAssetCollection:(void (^)(LXAssetCollection * _Nonnull))completionHandler {
    ASYNC_THREAD(
      if (completionHandler) {
        ASYNC_MAINTHREAD(
            completionHandler(self.assetCollections.firstObject);
        )
      }
    )
}

-(void)fetchRecentsAssetItems:(void (^)(NSArray<LXAssetItem *> * _Nullable))completionHandler {
    ASYNC_THREAD(
      if (completionHandler) {
        LXAssetCollection *assetCollection = self.assetCollections.firstObject;
         if (assetCollection) {
             [assetCollection fetchAllAssets:^(NSArray<LXAssetItem *> * _Nonnull assetItems) {
                 ASYNC_MAINTHREAD(
                   completionHandler(assetItems);
                  )
             }];
         }else{
             ASYNC_MAINTHREAD(
               completionHandler(nil);
             )
         }
      }
    )
}

- (void)reloadAllAssetCollections:(NSArray<NSNumber *> *)types{
    if (!types || types.count == 0) {
        types = self.types;
    }
    
    [LXAuthorManager checkAuthorization:LXAuthorizationTypePhoto
                               callBack:^(BOOL isPass) {
        if (isPass) {
            ASYNC_THREAD(
             [self.assetCollections removeAllObjects];
             [types enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj,
                                                 NSUInteger idx,
                                                 BOOL * _Nonnull stop) {
                 if ([self.types containsObject:obj]) {
                     [self fetchCollectionWithType:obj.integerValue];
                 }
             }];
            )
        }
    }];
}

- (void)clearAllCollections {
    ASYNC_THREAD(
      [self.assetCollections removeAllObjects];
      [[LXAssetCache shared].memoryCache removeAllObjects];
     )
}

/// 获取系统相册
-(NSArray<LXAssetCollection *> *)fetchCollectionWithType:(PHAssetCollectionType)type {
    PHFetchResult<PHAssetCollection *> *collections;
    collections = [PHAssetCollection fetchAssetCollectionsWithType:type
                                                           subtype:PHAssetCollectionSubtypeAny
                                                           options:nil];
    @LXWeakObj(self);
    [collections enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection,
                                              NSUInteger idx, BOOL * _Nonnull stop) {
        @LXStrongObj(self);
        LXAssetCollection *assetCollection = [self creatAssetCollectionFrom:collection];
        if (assetCollection && assetCollection.firstAssetItem) {
            if (collection.assetCollectionType == PHAssetCollectionTypeAlbum &&
                collection.assetCollectionSubtype == PHAssetCollectionSubtypeAlbumRegular) {
                assetCollection.title = collection.localizedTitle;
                [self.assetCollections addObject:assetCollection];
            }else{
                assetCollection.title = [self transformAblumTitle:collection.localizedTitle];
                if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary ||
                    collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded) {
                    [self.assetCollections insertObject:assetCollection atIndex:0];
                }else{
                    [self.assetCollections addObject:assetCollection];
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

/// 检查有效性
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


