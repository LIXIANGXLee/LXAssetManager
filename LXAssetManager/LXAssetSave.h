//
//  LXAssetSave.h
//  LXAssetManager
//
//  Created by 李响 on 2020/2/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**成功回调*/
typedef void(^SuccessCallBlock)(void);
/**失败回调*/
typedef void(^FailCallBlock)(NSString *error);

@interface LXAssetSave : NSObject


/**将视频写入相册
 * - parameter:
 * - url 视频资源
 * - assetCollectionTitle 相册名称，推荐使用宏 PROJECT_NAME
 * - successCallBack 成功回调
 * - failCallBack 失败回调
 */
+ (void)saveVideoToassetWithUrl:(NSURL *)url
           assetCollectionTitle:(NSString *)assetCollectionTitle
                        success:(SuccessCallBlock)successCallBack
                           fail:(FailCallBlock)failCallBack API_AVAILABLE(ios(9.0));


/**将图片写入相册
 * - parameter:
 * - image 图片资源
 * - assetCollectionTitle 相册名称，推荐使用宏 PROJECT_NAME
 * - successCallBack 成功回调
 * - failCallBack 失败回调
 */
+ (void)saveImageToassetWithImage:(UIImage *)image
             assetCollectionTitle:(NSString *)assetCollectionTitle
                          success:(SuccessCallBlock __nullable)successCallBack
                             fail:(FailCallBlock __nullable)failCallBack API_AVAILABLE(ios(9.0));

@end

NS_ASSUME_NONNULL_END
