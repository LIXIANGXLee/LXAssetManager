//
//  LXAuthorManager.m
//  LXAssetManager
//
//  Created by 李响 on 2020/6/9.
//

#import "LXAuthorManager.h"
#import <Photos/Photos.h>

@implementation LXAuthorManager

/// 检查权限
+ (void)checkAuthorization:(LXAuthorizationType)type
                  callBack:(LXAuthorizationCallBack)callBack {
    switch (type) {
        case LXAuthorizationTypePhoto:
            [self checkPhotoAuthorization:callBack];
            break;
        case LXAuthorizationTypeVideo:
            [self checkCameraAuthorizationWithType:AVMediaTypeVideo
                                          callBack:callBack];
            break;
        case LXAuthorizationTypeAudio:
            [self checkCameraAuthorizationWithType:AVMediaTypeAudio
                                          callBack:callBack];
            break;
        default:
            [self checkPhotoAuthorization:callBack];
            break;
    }
}

/// 检查相册权限
+ (void)checkPhotoAuthorization:(LXAuthorizationCallBack)callBack{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted) {
        [self unableAccessPermissions:@"无法访问您的相册权限"
                             callBack:callBack];
    } else if (status == PHAuthorizationStatusDenied) {
        [self expectAccessPermissions:@"开启相册权限"
                              message:[NSString stringWithFormat:@"“%@”想访问您的照片，开启后即可使用相册图片",
                                       PROJECT_NAME]
                             callBack:callBack];
    } else if (status == PHAuthorizationStatusAuthorized) {
           callBack(YES);
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            callBack(status == PHAuthorizationStatusAuthorized);
        }];
    }
}

/// 检查相机权限
+ (void)checkCameraAuthorizationWithType:(AVMediaType)type
                                callBack:(LXAuthorizationCallBack)callBack{
     AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:type];
    if (status == AVAuthorizationStatusRestricted) {
        if (type == AVMediaTypeAudio) {
            [self unableAccessPermissions:@"无法访问您的相机权限"
                                 callBack:callBack];
        }else if (type == AVMediaTypeVideo){
            [self unableAccessPermissions:@"无法访问您的相机权限"
                                 callBack:callBack];
        }
    } else if (status == AVAuthorizationStatusDenied) {
        if (type == AVMediaTypeAudio) {
            [self expectAccessPermissions:@"开启麦克风权限"
                                  message:[NSString stringWithFormat:@"“%@”想访问您的麦克风，开启之后即可录音或播音",
                                           PROJECT_NAME]
                                 callBack:callBack];
        }else if (type == AVMediaTypeVideo){
            [self expectAccessPermissions:@"开启相机权限"
                                  message:[NSString stringWithFormat:@"“%@”想访问您的相机，开启之后即可拍照或者拍摄",
                                                             PROJECT_NAME]
                                 callBack:callBack];
        }
    } else if (status == AVAuthorizationStatusAuthorized) {
           callBack(YES);
    } else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:type
                                 completionHandler:^(BOOL granted) {
            callBack(granted);
        }];
    }
}

/// 去设置权限
+ (void)jumpToSettingAppDirectly{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        if (@available(iOS 10.0, *)){
            [[UIApplication sharedApplication] openURL:url
                                               options:@{}
                                     completionHandler:nil];
        }else{
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] openURL:url];
        #pragma clang diagnostic pop
        }
    }
}

/// 无法访问您的权限
+ (void)unableAccessPermissions:(NSString *)title
                       callBack:(LXAuthorizationCallBack)callBack {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:@""
                                                                      preferredStyle: UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [[self visibleViewController] presentViewController:alertController
                                               animated:YES completion:^{
        callBack(NO);
    }];
}

/// 推荐打开权限
+(void)expectAccessPermissions: (NSString *)title
                       message: (NSString *)message
                      callBack:(LXAuthorizationCallBack)callBack {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"以后再说"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"设置"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [self jumpToSettingAppDirectly];
    }]];
    [[self visibleViewController] presentViewController:alertController
                                               animated:YES completion:^{
        callBack(NO);
    }];
}

/// 跟控制器
+ (UIViewController *)getRootViewController{
    UIWindow* window = [UIApplication sharedApplication].windows.firstObject;
    NSAssert(window, @"The window is empty");
    return window.rootViewController;
}

/// 当前显示的控制器
+ (UIViewController *)visibleViewController {
    UIViewController* currentViewController = [self getRootViewController];
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else {
            if ([currentViewController isKindOfClass:[UINavigationController class]]) {
                currentViewController = ((UINavigationController *)currentViewController).visibleViewController;
            } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
                currentViewController = ((UITabBarController* )currentViewController).selectedViewController;
            } else if ([currentViewController isKindOfClass:[UISplitViewController class]]) { // 当需要兼容 Ipad 时
                currentViewController = currentViewController.presentingViewController;
            } else {
                if (currentViewController.presentingViewController) {
                    currentViewController = currentViewController.presentingViewController;
                } else {
                    return currentViewController;
                }
            }
        }
    }
    return currentViewController;
}


@end
