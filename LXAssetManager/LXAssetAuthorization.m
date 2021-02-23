//
//  LXAssetAuthorization.m
//  LXAssetManager
//
//  Created by 李响 on 2021/2/23.
//

#import "LXAssetAuthorization.h"
#import <Photos/Photos.h>

@implementation LXAssetAuthorization

///检查相册权限
+ (void)checkPhotoAuthorization:(AuthorizationCallBack)callBack{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
   
    if (status == PHAuthorizationStatusRestricted) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法访问相册权限" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [[[[[UIApplication sharedApplication] windows] firstObject] rootViewController] presentViewController:alertController animated:YES completion:^{
            callBack(NO);
        }];
    } else if (status == PHAuthorizationStatusDenied) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法访问相册权限" message:@"请在手机的设置>隐私>相机中开启您的相册访问权限" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]){
                if (@available(iOS 10.0, *)){
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                }else{
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [[UIApplication sharedApplication] openURL:url];
                #pragma clang diagnostic pop
                }
            }
        }]];
        [[[[[UIApplication sharedApplication] windows] firstObject] rootViewController] presentViewController:alertController animated:YES completion:^{
            callBack(NO);
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
           callBack(YES);
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            callBack(status == PHAuthorizationStatusAuthorized);
        }];
    }
}

/// 检测音频权限
+ (void)checkCameraAuthorizationWithAudio:(AuthorizationCallBack)callBack{
    [self checkCameraAuthorizationWithType:AVMediaTypeAudio callBack:callBack];
}

///检测视频权限
+ (void)checkCameraAuthorizationWithVideo:(AuthorizationCallBack)callBack{
    [self checkCameraAuthorizationWithType:AVMediaTypeVideo callBack:callBack];
}

/// 检测相机权限
+ (void)checkCameraAuthorizationWithType:(AVMediaType)type callBack:(AuthorizationCallBack)callBack{
    
     AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:type];
    if (status == AVAuthorizationStatusRestricted) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法访问相册权限" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [[[[[UIApplication sharedApplication] windows] firstObject] rootViewController] presentViewController:alertController animated:YES completion:^{
            callBack(NO);
        }];
    } else if (status == AVAuthorizationStatusDenied) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法访问相册权限" message:@"请在手机的设置>隐私>相机中开启您的相册访问权限" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]){
                if (@available(iOS 10.0, *)){
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                }else{
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [[UIApplication sharedApplication] openURL:url];
                #pragma clang diagnostic pop
                }
            }
        }]];
        [[[[[UIApplication sharedApplication] windows] firstObject] rootViewController] presentViewController:alertController animated:YES completion:^{
            callBack(NO);
        }];
    } else if (status == AVAuthorizationStatusAuthorized) {
           callBack(YES);
    } else if (status == AVAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            callBack(status == PHAuthorizationStatusAuthorized);
        }];
    }

}

@end
