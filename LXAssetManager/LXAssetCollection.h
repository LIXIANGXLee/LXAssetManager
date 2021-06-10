//
//  LXAssetModel.h
//  LXAssetManager
//
//  Created by 李响 on 2020/3/9.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "LXAssetItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LXAssetType){
    LXAssetTypeAll = 0,   /// 所有资源
    LXAssetTypeVideo,     /// 视频资源
    LXAssetTypeImage      /// 图片资源
};

/// 相册模型
@interface LXAssetCollection : NSObject

/// 相册名字
@property(nonatomic, strong)NSString *title;

/// 相册资源数量
@property(nonatomic, assign)NSInteger assetCount;

/// 相册第一个资源
@property(nonatomic, weak)LXAssetItem *firstAssetItem;

/// 相册
@property(nonatomic, strong)PHAssetCollection *assetCollection;

/// 队列(内部队列，外界不要修改)
@property(nonatomic, weak)dispatch_queue_t fetchQueue;

/// 按照时间排序
/// @param isAscending 资源根据时间排序的 isAscending == YES 升序
/// 默认排序是降序排序 如果不执行此方法，获取的数据就是降序排序数据
- (void)sortAllAssetsWithAscending:(BOOL)isAscending;

/// 根据相册名获取相册下的所有phasset资源
- (void)fetchAllAssets:(void(^)(NSArray<LXAssetItem *> *assetItems))completionHandler;

/// 将资源按类型过滤
/// @param type 需要的源类型
/// @param completionHandler 回调参数
- (void)filterAssetsWithType:(LXAssetType)type
        handle:(void(^)(NSArray<LXAssetItem *> *assetItems))completionHandler;
                          
/// 重置当前相册下的资源的选中次数为0 和 userInfo 为初始值,
/// 也可以用户手动去设置
- (void)resetAssetItem;

@end

NS_ASSUME_NONNULL_END
