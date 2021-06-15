//
//  LXAssetItem.h
//  LXAssetManager
//
//  Created by 李响 on 2020/3/9.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LXAssetImageType) {
    LXAssetImageTypeThumbnail = 0,  /// 缩略图
    LXAssetImageTypeMiddle,         /// 中等图
    LXAssetImageTypeOrigin          /// 原图
};

typedef NS_ENUM(NSInteger, LXAssetCloudStatus) {
    LXAssetCloudStatusNone = 0,          /// 默认
    LXAssetCloudStatusDownloading,       /// 在云正在下载
    LXAssetCloudStatusDownloadedSucc,    /// 在云下载完毕
    LXAssetCloudStatusDownloadedFail,    /// 在云下载失败
    LXAssetCloudStatusDownloadedCancel   /// 在云下载取消
};

@class LXAssetItem;
/// 从cloud加载数据的进度处理
typedef void (^FetchCloudProgressHandler)(double progress);
/// 从cloud加载数据完成回调处理
typedef void (^FetchCloudCompletionHandler)(LXAssetItem * _Nullable assetItem);

@interface LXAssetItem : NSObject

/// phasset资源数据
@property(nonatomic, strong)PHAsset *phasset;

/// 是否云下载状态
@property(nonatomic, assign)LXAssetCloudStatus status;

/// 当前资源被选中的次数
@property(nonatomic, assign)NSInteger number;

/// 额外字段 日后方便存储一些UI需要有用的数据（比如蒙层隐藏啊 展示啊等等，需要手动设置其内容）
/// 暂时没用上
@property(nonatomic, strong)NSMutableDictionary *userInfo;

/// 获取资源图片 LXAssetImageType == LXAssetImageTypeThumbnai
/// 使用SDwebimage做了图片异步解码和图片内存缓存机制，让数据显示UI更流畅 更快捷
/// 其他类型LXAssetImageTypeMiddle LXAssetImageTypeOrigin只做了图片异步解码
/// @param type 资源类型
- (void)fetchImage:(LXAssetImageType)type
           handler:(void(^)(UIImage * _Nullable image))completionHandler;

/// 获取缩略图，使用SDwebimage做了图片异步解码和图片内存缓存机制，让数据显示UI更流畅 更快捷
- (void)fetchImageWithThumbnail:(void(^)(UIImage * _Nullable image))completionHandler;

/// 判断资源是否为视频
- (BOOL)isVideo;

/// 判断资源是否为图片
- (BOOL)isImage;

/// 同步检查资源是否在云上
- (BOOL)checkAssetInCloud;

/// 获取云cloud asset资源
/// @param progressHandler 进度回调
/// @param completionHandler 完成回调
- (void)requestCloudData:(FetchCloudProgressHandler _Nullable)progressHandler
              completion:(FetchCloudCompletionHandler _Nullable)completionHandler;

/// 取消云下载任务
- (void)cancelRequestDataFromCloud;

/// 重写判断两个对象是否相等
/// @param object 传进来的对象
- (BOOL)isEqual:(LXAssetItem *)object;

@end

NS_ASSUME_NONNULL_END
