//
//  LXAssetItem.m
//  LXAssetManager
//
//  Created by 李响 on 2020/3/9.
//

#import "LXAssetItem.h"
#import <SDWebImage/SDWebImage.h>
#import "LXAssetCache.h"
#import "LXAssetManager.h"
#import "LXAssetDefine.h"

@interface LXAssetItem()

@property(nonatomic, copy)FetchCloudProgressHandler progressHandler;
@property(nonatomic, copy)FetchCloudCompletionHandler completionHandler;

@end

@implementation LXAssetItem{
    BOOL _checkIfInCloud; //保存状态避免重复检查
    BOOL _isAssetInCloud;
    PHImageRequestID _requestId;
 }

- (instancetype)init{
    self = [super init];
    if (self) {
        _checkIfInCloud = false;
        _isAssetInCloud = false;
        self.status = LXAssetCloudStatusNone;
        self.userInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)isVideo {
    return self.phasset.mediaType == PHAssetMediaTypeVideo;
}
- (BOOL)isImage {
    return self.phasset.mediaType == PHAssetMediaTypeImage;
}

-(void)fetchImageWithThumbnail:(void (^)(UIImage * _Nullable))completionHandler {
    [self fetchImage:LXAssetImageTypeThumbnail handler:completionHandler];
}

- (void)fetchImage:(LXAssetImageType)type handler:(void (^)(UIImage * _Nullable))completionHandler {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
     CGSize size = CGSizeZero;
     switch (type) {
         case LXAssetImageTypeThumbnail:{
            UIImage *image = [[LXAssetCache shared].memoryCache objectForKey:self.phasset.localIdentifier];
             if (image) {
                 ASYNC_MAINTHREAD(
                     if (completionHandler) {
                         completionHandler(image);
                     }
                 )
                 return;
             }
             size = CGSizeMake(SCREEN_WDITH_A/4, SCREEN_WDITH_A/4);
           }
             break;
         case LXAssetImageTypeMiddle:
             size = CGSizeMake(SCREEN_WDITH_A/2, SCREEN_WDITH_A/2);
             break;
         case LXAssetImageTypeOrigin:
             size = PHImageManagerMaximumSize;
             break;
         default:
             break;
       }

        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.synchronous = YES;
        [[PHImageManager defaultManager] requestImageForAsset:self.phasset
                                                   targetSize:size contentMode:PHImageContentModeAspectFill
                                                      options:option
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                UIImage *image = [SDImageCoderHelper decodedImageWithImage:result];
                ASYNC_MAINTHREAD(
                     if (type == LXAssetImageTypeThumbnail && image) {
                         [[LXAssetCache shared].memoryCache setObject:image
                                                               forKey:self.phasset.localIdentifier  cost:image.sd_memoryCost];
                     }
                     if (completionHandler) {
                         completionHandler(image);
                     }
                )
            }
        }];
    });
}

 - (BOOL)checkAssetInCloud {
     if (self.phasset == nil || (![self isVideo] && ![self isImage])) {
         //只检查了图片和视频资源是否在云上
         return NO;
     }
     
     /// 判断是否检查过
     if (_checkIfInCloud) { return _isAssetInCloud; }
     
     __block BOOL isInICloud = NO;
     dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
     @autoreleasepool {
         if ([self isVideo]) {
             PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
             options.version = PHVideoRequestOptionsVersionOriginal;
             options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
             [[PHImageManager defaultManager] requestAVAssetForVideo:self.phasset
                                                             options:options
                                                       resultHandler:^(AVAsset * avAsset,
                                                                       AVAudioMix * audioMix,
                                                                       NSDictionary * info) {
                 if (!avAsset) {
                     isInICloud = YES;
                 }
                 dispatch_semaphore_signal(semaphore);
             }];
         } else if ([self isImage]) {
             PHImageRequestOptions *options = [PHImageRequestOptions new];
             options.version = PHImageRequestOptionsVersionOriginal;
             options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
             options.synchronous = YES;
             [[PHImageManager defaultManager] requestImageDataForAsset:self.phasset
                                                               options:options
                                                         resultHandler:^(NSData * _Nullable imageData,
                                                                         NSString * _Nullable dataUTI,
                                                                         UIImageOrientation orientation,
                                                                         NSDictionary * _Nullable info) {
                 if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !imageData) {
                     isInICloud = YES;
                 }
                 dispatch_semaphore_signal(semaphore);
             }];
         }
         dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
     }
     _checkIfInCloud = true;
     _isAssetInCloud = isInICloud;
     return isInICloud;
 }

 - (void)requestCloudData:(FetchCloudProgressHandler)progressHandler completion:(FetchCloudCompletionHandler)completionHandler {
     self.progressHandler = progressHandler;
     self.completionHandler = completionHandler;
     self.status = LXAssetCloudStatusDownloading;
     if ([self isImage]) {
         [self requestImageFromCloud];
     } else if ([self isVideo]) {
         [self requestVideoFromCloud];
     }
 }

 /// 从云上获取图片
 - (void)requestImageFromCloud {
     @LXWeakObj(self)
     PHImageRequestOptions *options = [PHImageRequestOptions new];
     options.resizeMode = PHImageRequestOptionsResizeModeFast;
     options.version = PHImageRequestOptionsVersionOriginal;
     options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
     options.networkAccessAllowed = YES;
     options.progressHandler = ^(double progress, NSError *__nullable error,
                                 BOOL *stop, NSDictionary *__nullable info) {
         @LXStrongObj(self)
         ASYNC_MAINTHREAD(
             if (self.progressHandler) {
                 self.progressHandler(progress);
             }
         )
     };
     
     PHImageManager * manager = [PHImageManager defaultManager];
     _requestId = [manager requestImageDataForAsset:self.phasset
                                            options:options
                                      resultHandler:^(NSData * _Nullable imageData,
                                                      NSString * _Nullable dataUTI,
                                                      UIImageOrientation orientation,
                                                      NSDictionary * _Nullable info) {
         @LXStrongObj(self)
         ASYNC_MAINTHREAD(
             if (imageData) {
                 self.status = LXAssetCloudStatusDownloadedSucc;
                 if (self.completionHandler) {
                     self.completionHandler(self);
                 }
             } else {
                 if ([info[PHImageCancelledKey] boolValue]) {//如果不是取消
                     self.status = LXAssetCloudStatusDownloadedCancel;
                 }else{
                     self.status = LXAssetCloudStatusDownloadedFail;
                 }
                 if (self.completionHandler) {
                     self.completionHandler(nil);
                 }
             }
         )
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
         ASYNC_MAINTHREAD(
             if (weakSelf.progressHandler) {
                 weakSelf.progressHandler(progress);
             }
         )
     };
     PHImageManager * manager = [PHImageManager defaultManager];
     _requestId = [manager requestAVAssetForVideo:self.phasset
                                          options:option
                                    resultHandler:^(AVAsset * _Nullable asset,
                                                    AVAudioMix * _Nullable audioMix,
                                                    NSDictionary * _Nullable info) {
         ASYNC_MAINTHREAD(
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
         )
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
