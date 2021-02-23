//
//  LXAssetAuthorization.h
//  LXAssetManager
//
//  Created by 李响 on 2021/2/23.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 判断授权是否通过
typedef void(^AuthorizationCallBack)(BOOL isPass);

@interface LXAssetAuthorization : NSObject

///检查相册权限
+ (void)checkPhotoAuthorization:(AuthorizationCallBack)callBack;

/// 检测音频权限
+ (void)checkCameraAuthorizationWithAudio:(AuthorizationCallBack)callBack;

///检测视频权限
+ (void)checkCameraAuthorizationWithVideo:(AuthorizationCallBack)callBack;

/// 检测相机权限
+ (void)checkCameraAuthorizationWithType:(AVMediaType)type callBack:(AuthorizationCallBack)callBack;
 
@end

NS_ASSUME_NONNULL_END
