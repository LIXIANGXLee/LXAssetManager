//
//  LXAssetModel.m
//  LXAssetManager
//
//  Created by 李响 on 2020/3/9.
//

#import "LXAssetCollection.h"

@interface LXAssetCollection()
@property (nonatomic, strong)NSMutableArray<LXAssetItem *> *assetItems;

@end

@implementation LXAssetCollection

-(void)setAssetCollection:(PHAssetCollection *)assetCollection {
    _assetCollection = assetCollection;
    [self sortAllAssetsWithAscending:NO];
    self.assetCount = self.assetItems.count;
    self.firstAssetItem = self.assetItems.firstObject;
}

- (void)sortAllAssetsWithAscending:(BOOL)isAscending {
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        dispatch_async(self.fetchQueue, ^{
            [self _sortAllAssetsWithAscending:isAscending];
        });
    }else{
        [self _sortAllAssetsWithAscending:isAscending];
    }
}

- (void)_sortAllAssetsWithAscending:(BOOL)isAscending {
    [self.assetItems removeLastObject];
    PHFetchResult * result = [self fetchAssetsInAssetCollection:self.assetCollection
                                                      ascending:isAscending];
    [result enumerateObjectsUsingBlock:^(PHAsset *phasset, NSUInteger idx, BOOL * _Nonnull stop) {
        LXAssetItem * assetItem = [[LXAssetItem alloc] init];
        assetItem.phasset = phasset;
        [self.assetItems addObject:assetItem];
    }];
}

-(void)fetchAllAssets:(void (^)(NSArray<LXAssetItem *> * _Nonnull))completionHandler {
    dispatch_async(self.fetchQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) {
                completionHandler(self.assetItems);
            }
        });
    });
}

- (void)filterAssetsWithType:(LXAssetType)type
                      handle:(void (^)(NSArray<LXAssetItem *> * _Nonnull))completionHandler {
    dispatch_async(self.fetchQueue, ^{
        NSPredicate *predicate = nil;
        switch (type) {
            case LXAssetTypeAll:
                predicate = [NSPredicate predicateWithValue:YES];
                break;
            case LXAssetTypeImage: {
                [NSPredicate predicateWithBlock:^BOOL(LXAssetItem *assetItem,
                                                      NSDictionary<NSString *,id> * _Nullable bindings) {
                    return assetItem.phasset.mediaType == PHAssetMediaTypeImage;
                }];
            }
            break;
            case LXAssetTypeVideo: {
                [NSPredicate predicateWithBlock:^BOOL(LXAssetItem *assetItem,
                                                      NSDictionary<NSString *,id> * _Nullable bindings) {
                    return assetItem.phasset.mediaType == PHAssetMediaTypeVideo;
                }];
            }
            break;
        }
       dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) {
                completionHandler([self.assetItems filteredArrayUsingPredicate:predicate]);
            }
        });
    });
}

- (void)resetAssetItem {
    dispatch_async(self.fetchQueue, ^{
        [self.assetItems enumerateObjectsUsingBlock:^(LXAssetItem *assetItem,
                                                      NSUInteger idx, BOOL * _Nonnull stop) {
            assetItem.number = 0;
            [assetItem.userInfo removeAllObjects];
        }];
    });
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

