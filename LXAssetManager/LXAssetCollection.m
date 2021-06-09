//
//  LXAssetModel.m
//  LXAssetManager
//
//  Created by 李响 on 2020/3/9.
//

#import "LXAssetCollection.h"
#import <SDWebImage/SDWebImage.h>

#define SCREEN_WDITH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

@implementation LXAssetCollection

- (NSArray<LXAssetItem *> *)fetchAllAssetsWithAscending:(BOOL *)isAscending {
    PHFetchResult * result = [self fetchAssetsInAssetCollection:self.assetCollection
                                                      ascending:isAscending];
    NSMutableArray * assetItems = [NSMutableArray array];
    [result enumerateObjectsUsingBlock:^(PHAsset *phasset, NSUInteger idx, BOOL * _Nonnull stop) {
        LXAssetItem * assetItem = [[LXAssetItem alloc] init];
        assetItem.phasset = phasset;
        [assetItems addObject:assetItem];
    }];
    return assetItems;
}

- (NSArray<LXAssetItem *> *)filterAssetsWithType:(LXAssetType)type
                                       ascending:(BOOL *)isAscending {
    NSPredicate *predicate = nil;
    switch (type) {
        case LXAssetTypeAll:
            predicate = [NSPredicate predicateWithValue:YES];
            break;
        case LXAssetTypeImage: {
            [NSPredicate predicateWithBlock:^BOOL(LXAssetItem *assetItem, NSDictionary<NSString *,id> * _Nullable bindings) {
                return assetItem.phasset.mediaType == PHAssetMediaTypeImage;
            }];
        }
        break;
        case LXAssetTypeVideo: {
            [NSPredicate predicateWithBlock:^BOOL(LXAssetItem *assetItem, NSDictionary<NSString *,id> * _Nullable bindings) {
                return assetItem.phasset.mediaType == PHAssetMediaTypeVideo;
            }];
        }
        break;
        default:
        break;
    }
    return [[self fetchAllAssetsWithAscending:isAscending] filteredArrayUsingPredicate:predicate];
}

/**获取图片和视频资源*/
- (PHFetchResult <PHAsset *> *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection
                                                  ascending:(BOOL)ascending {
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
}

@end

@interface LXAssetItem()
@property(nonatomic, copy)FetchCloudProgressHandler progressHandler;
@property(nonatomic, copy)FetchCloudCompletionHandler completionHandler;

@end

@implementation LXAssetItem
{
   BOOL _hadCheckIfInCloud; //保存状态避免重复检查
   BOOL _isAssetInCloud;
   
   PHImageRequestID _requestId;
}

- (UIImage *)fetchImage:(LXAssetImageType)type {
    CGSize size = CGSizeZero;
    
    switch (type) {
        case LXAssetImageTypeThumbnail:
            size = CGSizeMake(SCREEN_WDITH/4, SCREEN_WDITH/4);
            break;
        case LXAssetImageTypeMiddle:
            size = CGSizeMake(SCREEN_WDITH/2, SCREEN_WDITH/2);
            break;
        case LXAssetImageTypeOrigin:
            size = PHImageManagerMaximumSize;
            break;
        default:
            break;
    }
    
    __block UIImage *image = nil;
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.synchronous = YES;
    [[PHImageManager defaultManager] requestImageForAsset:_phasset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            image = [SDImageCoderHelper decodedImageWithImage:result];
        }
    }];
    
    return image;
}

- (BOOL)checkAssetInCloud {
    
    
    
    
    
    return YES;
    
}

- (void)requestCloudData:(FetchCloudProgressHandler)progressHandler completion:(FetchCloudCompletionHandler)completionHandler {
    self.progressHandler = progressHandler;
    self.completionHandler = completionHandler;
    self.status = LXAssetCloudStatusDownloading;
    
    if (self.phasset.mediaType == PHAssetMediaTypeImage) {
        [self requestImageFromCloud];
    } else if (self.phasset.mediaType == PHAssetMediaTypeVideo) {
        [self requestVideoFromCloud];
    }
}

/// 从云上获取图片
- (void)requestImageFromCloud {
    __weak typeof(self) weakSelf = self;
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.version = PHImageRequestOptionsVersionOriginal;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress,
                                NSError *__nullable error,
                                BOOL *stop,
                                NSDictionary *__nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.progressHandler) {
                weakSelf.progressHandler(progress);
            }
        });
    };
    
    PHImageManager * manager = [PHImageManager defaultManager];
    _requestId = [manager requestImageDataForAsset:self.phasset
                                           options:options
                                     resultHandler:^(NSData * _Nullable imageData,
                                                     NSString * _Nullable dataUTI,
                                                     UIImageOrientation orientation,
                                                     NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imageData) {
                weakSelf.status = LXAssetCloudStatusDownloadedSucc;
                if (weakSelf.completionHandler) {
                    weakSelf.completionHandler(weakSelf);
                }
            } else {
                if ([info[PHImageCancelledKey] boolValue]) {//如果不是取消
                    weakSelf.status = LXAssetCloudStatusDownloadedCancel;
                }else{
                    weakSelf.status = LXAssetCloudStatusDownloadedFail;
                }
                if (weakSelf.completionHandler) {
                    weakSelf.completionHandler(nil);
                }
            }
        });
    }];
}

/// 从云上获取视频
- (void)requestVideoFromCloud {
    __weak typeof(self) weakSelf = self;
    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    option.version = PHVideoRequestOptionsVersionOriginal;
    option.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    option.progressHandler = ^(double progress,
                               NSError *__nullable error,
                               BOOL *stop,
                               NSDictionary *__nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.progressHandler) {
                weakSelf.progressHandler(progress);
            }
        });
    };
    PHImageManager * manager = [PHImageManager defaultManager];
    _requestId = [manager requestAVAssetForVideo:self.phasset
                                         options:option
                                   resultHandler:^(AVAsset * _Nullable asset,
                                                   AVAudioMix * _Nullable audioMix,
                                                   NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (asset) {
                weakSelf.status = LXAssetCloudStatusDownloadedSucc;
                if (weakSelf.completionHandler) {
                    weakSelf.completionHandler(weakSelf);
                }
            } else {
                if ([info[PHImageCancelledKey] boolValue]) {//如果不是取消
                    weakSelf.status = LXAssetCloudStatusDownloadedCancel;
                }else{
                    weakSelf.status = LXAssetCloudStatusDownloadedFail;
                }
                if (weakSelf.completionHandler) {
                    weakSelf.completionHandler(nil);
                }
            }
        });
    }];
}

- (void)cancelRequestDataFromCloud {
    [[PHImageManager defaultManager] cancelImageRequest:_requestId];
}

- (BOOL)isEqual:(LXAssetItem *)object {
    if (self.phasset == nil || object.phasset == nil) {
        return false;
    }
    return self.phasset.localIdentifier.hash == object.phasset.localIdentifier.hash;
}

@end

