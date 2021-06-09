//
//  LXAuthorManager.h
//  LXAssetManager
//
//  Created by 李响 on 2020/6/9.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

#define PROJECT_NAME [NSBundle mainBundle].infoDictionary[@"CFBundleName"]

/// 判断授权是否通过
typedef void(^LXAuthorizationCallBack)(BOOL isPass);

typedef enum : NSUInteger {
    LXAuthorizationTypePhoto = 0, /// 图片（相册）
    LXAuthorizationTypeAudio,     /// 音频（麦克风）
    LXAuthorizationTypeVideo,     /// 视频（相机）
} LXAuthorizationType;

@interface LXAuthorManager : NSObject

/** 检查权限
 * - type 类型 LXAuthorizationTypePhoto，
 *            LXAuthorizationTypeAudio，
 *            LXAuthorizationTypeVideo
 * - callBack 权限结果回调
 */
+ (void)checkAuthorization:(LXAuthorizationType)type
                  callBack:(LXAuthorizationCallBack)callBack;
 
@end

NS_ASSUME_NONNULL_END
