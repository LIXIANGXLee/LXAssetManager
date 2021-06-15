//
//  LXAssetSave.m
//  LXAssetManager
//
//  Created by 李响 on 2020/2/23.
//

#import "LXAssetSave.h"
#import <Photos/Photos.h>
#import "LXAuthorManager.h"
#import "LXAssetDefine.h"

@implementation LXAssetSave

/**将视频写入相册
 * - parameter:
 * - url 视频资源
 * - assetCollectionTitle 相册名称
 * - successCallBack 成功回调
 * - failCallBack 失败回调
 */
+ (void)saveVideoToassetWithUrl:(NSURL *)url
           assetCollectionTitle:(NSString *)assetCollectionTitle
                        success:(SuccessCallBlock)successCallBack
                           fail:(FailCallBlock)failCallBack API_AVAILABLE(ios(9.0)){
    // 授权
    @LXWeakObj(self)
    [LXAuthorManager checkAuthorization:LXAuthorizationTypePhoto
                               callBack:^(BOOL isPass) {
        if (isPass) {
            [self saveVideoToSystemWithUrl:url
                             completionHandler:^(BOOL success, NSError *error, NSString *assetUrlLocalIdentifier) {
                @LXStrongObj(self)
                if (success) {
                    [self saveAssetToCustomCollection:assetCollectionTitle
                                       assetLocalIdentifier:assetUrlLocalIdentifier
                                                    success:successCallBack
                                                       fail:failCallBack];
                }else{
                    ASYNC_MAINTHREAD(
                         if (failCallBack) {
                             failCallBack([error localizedFailureReason]);
                         }
                     )
                }
            }];
        }
    }];
}

/**将图片写入相册
 * - parameter:
 * - image 图片资源
 * - assetCollectionTitle 相册名称
 * - successCallBack 成功回调
 * - failCallBack 失败回调
 */
+ (void)saveImageToassetWithImage:(UIImage *)image
             assetCollectionTitle:(NSString *)assetCollectionTitle
                          success:(SuccessCallBlock)successCallBack
                             fail:(FailCallBlock)failCallBack API_AVAILABLE(ios(9.0)){
    // 授权
    @LXWeakObj(self)
    [LXAuthorManager checkAuthorization:LXAuthorizationTypePhoto
                               callBack:^(BOOL isPass) {
        if (isPass){ /// 已授权
            [self saveImageToSystemWithImage:image
                               completionHandler:^(BOOL success, NSError *error, NSString *assetImageLocalIdentifier) {
                @LXStrongObj(self)
                if (success){
                    [self saveAssetToCustomCollection:assetCollectionTitle
                                       assetLocalIdentifier:assetImageLocalIdentifier
                                                    success:successCallBack
                                                       fail:failCallBack];
                }else{
                    ASYNC_MAINTHREAD(
                        if (failCallBack) {
                            failCallBack([error localizedFailureReason]);
                        }
                    )
                }
            }];
        }
    }];
}

/// 添加资源到自定义相册
+ (void)saveAssetToCustomCollection:(NSString *)assetCollectionTitle
               assetLocalIdentifier:(NSString *)assetLocalIdentifier
                            success:(SuccessCallBlock)successCallBack
                               fail:(FailCallBlock)failCallBack{
    // 获得相簿
    @LXWeakObj(self)
    [self getAssetCollection:assetCollectionTitle
                    callBack:^(PHAssetCollection * _Nullable assetCollection) {
        @LXStrongObj(self)
        if (assetCollection){
            [self addCameraAssetToAlbum:assetLocalIdentifier
                              assetCollection:assetCollection
                            completionHandler:^(BOOL success, NSError *error) {
                ASYNC_MAINTHREAD(
                    if (success) {
                        if (successCallBack) { successCallBack(); }
                    }else {
                        if (failCallBack) { failCallBack([error localizedFailureReason]); }
                    }
                )
            }];
        }else{
            ASYNC_MAINTHREAD(
                if (failCallBack) { failCallBack(@"获取相册失败"); }
            )
        }
    }];
}

/// 保存图片资源到系统相册
+ (void)saveImageToSystemWithImage:(UIImage *)image
                 completionHandler:(void(^)(BOOL success, NSError *error,NSString *assetImageLocalIdentifier))completionHandler {
    
    __block NSString *assetImageLocalIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //保存图片A到"相机胶卷"中
        if (@available(iOS 9.0, *)) {
            assetImageLocalIdentifier = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        completionHandler(success,error,assetImageLocalIdentifier);
    }];
}

/// 保存视频资源到系统相册
+ (void)saveVideoToSystemWithUrl:(NSURL *)url
               completionHandler:(void(^)(BOOL success, NSError *error,NSString *assetUrlLocalIdentifier))completionHandler {
    
    __block NSString *assetUrlLocalIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //保存图片A到"相机胶卷"中
        if (@available(iOS 9.0, *)) {
            assetUrlLocalIdentifier = [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:url].placeholderForCreatedAsset.localIdentifier;

        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        completionHandler(success, error, assetUrlLocalIdentifier);
    }];
}

/// 添加相机资源到自定义相册
+ (void)addCameraAssetToAlbum:(NSString *)assetLocalIdentifier
              assetCollection:(PHAssetCollection *)assetCollection
            completionHandler:(void(^)(BOOL success, NSError *error))completionHandler {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 添加"相机胶卷"中的资源A到"相簿"D中
        //获取图片
        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetLocalIdentifier] options:nil].lastObject;
        // 添加图片到相簿中的请求
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        // 添加图片到相簿
        [request insertAssets:@[asset] atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        completionHandler(success, error);
    }];
}

///获取自定义相册
+ (void)getAssetCollection:(NSString *)assetCollectionTitle
                  callBack:(void(^)(PHAssetCollection * __nullable assetCollection))callBack{
    /// 查找相册
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *assetCollection in assetCollections) {
        if ([assetCollection.localizedTitle isEqualToString:assetCollectionTitle]) {
            callBack(assetCollection);
            return ;
        }
    }
    
    /// 创建相册
    NSError *error = nil;
    __block NSString *assetCollectionLocalIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        assetCollectionLocalIdentifier = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:assetCollectionTitle].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error){
        callBack(nil);
    }else{
        PHAssetCollection *assetCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[assetCollectionLocalIdentifier] options:nil].lastObject;
        callBack(assetCollection);
    }
}

@end
