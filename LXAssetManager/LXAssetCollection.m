//
//  LXAssetModel.m
//  LXAssetManager
//
//  Created by 李响 on 2020/3/9.
//

#import "LXAssetCollection.h"
#import "LXAssetManager.h"
#import "LXAssetDefine.h"

@interface LXAssetCollection()
@property (nonatomic, strong)NSMutableArray<LXAssetItem *> *assetItems;

@end

@implementation LXAssetCollection

-(void)setAssetCollection:(PHAssetCollection *)assetCollection {
    _assetCollection = assetCollection;
    [self reloadAllAssetsWithAscending:NO];
    self.assetCount = self.assetItems.count;
    self.firstAssetItem = self.assetItems.firstObject;
}

- (void)reloadAllAssetsWithAscending:(BOOL)isAscending {
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        ASYNC_THREAD(
           [self _sortAllAssetsWithAscending:isAscending];
         )
    }else{
        [self _sortAllAssetsWithAscending:isAscending];
    }
}

/// 刷新数据
- (void)_sortAllAssetsWithAscending:(BOOL)isAscending {
    [self.assetItems removeLastObject];
    PHFetchResult * result = [self fetchAssetsInAssetCollection:self.assetCollection
                                                      ascending:isAscending];
    [result enumerateObjectsUsingBlock:^(PHAsset *phasset,
                                         NSUInteger idx, BOOL * _Nonnull stop) {
        LXAssetItem * assetItem = [[LXAssetItem alloc] init];
        assetItem.phasset = phasset;
        [self.assetItems addObject:assetItem];
    }];
}

-(void)fetchAllAssets:(void (^)(NSArray<LXAssetItem *> * _Nonnull))completionHandler {
    ASYNC_THREAD(
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) {
                completionHandler(self.assetItems);
            }
        });
    )
}

- (void)fetchAllAsset:(void (^)(NSArray<LXAssetItem *> * _Nonnull,
                                NSArray<LXAssetItem *> * _Nonnull,
                                NSArray<LXAssetItem *> * _Nonnull))completionHandler {
    [self filterAssetsWithType:LXAssetTypeAll handle:^(NSArray<LXAssetItem *> * _Nonnull assetItems) {
        NSMutableArray *mVideo = [NSMutableArray array];
        NSMutableArray *mIMage = [NSMutableArray array];
        [assetItems enumerateObjectsUsingBlock:^(LXAssetItem * _Nonnull obj,
                                                 NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isVideo]) {
                [mVideo addObject:obj];
            }else if ([obj isImage]) {
                [mIMage addObject:obj];
            }
        }];
        if (completionHandler) {
            completionHandler(assetItems, [mVideo copy], [mIMage copy]);
        }
    }];
}

- (void)filterAssetsWithType:(LXAssetType)type
                      handle:(void (^)(NSArray<LXAssetItem *> * _Nonnull))completionHandler {
    ASYNC_THREAD(
        NSPredicate *predicate = nil;
        switch (type) {
            case LXAssetTypeAll:
                predicate = [NSPredicate predicateWithValue:YES];
                break;
            case LXAssetTypeImage: {
                [NSPredicate predicateWithBlock:^BOOL(LXAssetItem *assetItem,
                                                      NSDictionary<NSString *,id> * _Nullable bindings) {
                    return [assetItem isImage];
                }];
            } break;
            case LXAssetTypeVideo: {
                [NSPredicate predicateWithBlock:^BOOL(LXAssetItem *assetItem,
                                                      NSDictionary<NSString *,id> * _Nullable bindings) {
                    return [assetItem isVideo];
                }];
            } break;
        }
        NSArray * items = [self.assetItems filteredArrayUsingPredicate:predicate];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) {
                completionHandler(items);
            }
        });
     )
}

- (void)resetAssetItem {
    ASYNC_THREAD(
      [self.assetItems enumerateObjectsUsingBlock:^(LXAssetItem *assetItem,
                                                   NSUInteger idx, BOOL * _Nonnull stop) {
         assetItem.number = 0;
         [assetItem.userInfo removeAllObjects];
      }];
     )
}

/**获取图片和视频资源*/
- (PHFetchResult <PHAsset *> *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection
                                                  ascending:(BOOL)ascending {
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"
                                                             ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection
                                                          options:option];
    return result;
}

- (NSMutableArray<LXAssetItem *> *)assetItems {
    if (!_assetItems) {
        _assetItems = [NSMutableArray array];
    }
    return _assetItems;
}

@end

