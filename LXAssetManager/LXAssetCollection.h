//
//  LXAssetModel.h
//  LXAssetManager
//
//  Created by 李响 on 2020/3/9.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LXAssetType){
    LXAssetTypeAll = 0,   /// 所有资源
    LXAssetTypeVideo, /// 视频资源
    LXAssetTypeImage /// 图片资源
};

typedef NS_ENUM(NSInteger, LXAssetImageType) {
    LXAssetImageTypeThumbnail = 0, /// 缩略图
    LXAssetImageTypeMiddle,    /// 中等图
    LXAssetImageTypeOrigin    /// 原图
};

typedef NS_ENUM(NSInteger, LXAssetCloudStatus) {
    LXAssetCloudStatusDownloading = 0, /// 在云正在下载
    LXAssetCloudStatusDownloadedSucc,      /// 在云下载完毕
    LXAssetCloudStatusDownloadedFail,   /// 在云下载失败
    LXAssetCloudStatusDownloadedCancel  /// 在云下载取消

};

@class LXAssetItem;
typedef void (^FetchCloudProgressHandler)(double progress);
typedef void (^FetchCloudCompletionHandler)(LXAssetItem * __nullable assetItem);

/// 相册模型
@interface LXAssetCollection : NSObject

/// 相册名字
@property(nonatomic, strong)NSString *title;

/// 相册资源数量
@property(nonatomic, assign)int assetCount;

/// 相册第一个资源
@property(nonatomic, weak)LXAssetItem *firstAssetItem;

/// 相册
@property(nonatomic, strong)PHAssetCollection *assetCollection;

/// 是否为视频类型
@property(nonatomic, assign)BOOL isVideo;

/// 根据相册名获取相册下的所有phasset资源
/// @param isAscending 资源根据时间排序的 isAscending == YES 升序
- (NSArray<LXAssetItem *> *)fetchAllAssetsWithAscending:(BOOL *)isAscending;

/// 将资源按类型过滤
/// @param type 需要的源类型
/// @param isAscending 资源根据时间排序的 isAscending == YES 升序
- (NSArray<LXAssetItem *> *)filterAssetsWithType:(LXAssetType)type ascending:(BOOL *)isAscending;

@end

/// 单个资源
@interface LXAssetItem : NSObject

/// 资源数据
@property(nonatomic, strong)PHAsset *phasset;

/// 是否云下载状态
@property(nonatomic, assign)LXAssetCloudStatus status;

/// 当前资源被选中的次数
@property(nonatomic, assign)NSInteger number;

/// 获取资源图片
/// @param type 资源类型
/// LXAssetImageTypeThumbnail = 0, 缩略图
/// LXAssetImageTypeMiddle,        中等图
/// LXAssetImageTypeOrigin,        原图
- (UIImage * _Nullable)fetchImage:(LXAssetImageType)type;

/// 同步检查资源是否在云上
- (BOOL)checkAssetInCloud;

/// 获取云cloud asset资源
/// @param progressHandler 进度回调
/// @param completionHandler 完成回调
- (void)requestCloudData:(FetchCloudProgressHandler)progressHandler completion:(FetchCloudCompletionHandler)completionHandler;

/// 取消云下载任务
- (void)cancelRequestDataFromCloud;

/// 重写判断两个对象是否相等
/// @param object 传进来的对象
- (BOOL)isEqual:(LXAssetItem *)object;

@end

NS_ASSUME_NONNULL_END
