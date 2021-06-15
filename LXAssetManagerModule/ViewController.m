//
//  ViewController.m
//  LXAssetManagerModule
//
//  Created by 李响 on 2021/2/23.
//

#import "ViewController.h"
#import <LXAssetManager/LXAssetSave.h>
#import <LXAssetManager/LXAuthorManager.h>
#import <LXAssetManager/LXAssetManager.h>
#import <LXAssetManager/LXAssetCollection.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor redColor];
    
    
//    NSLog(@"============%@",[[LXAssetManager shared] filterAssetCollectionsWithType:LXAssetCollectionTypeUser]);
//
           [[LXAssetManager shared] reloadAllAssetCollections:nil];
            [[LXAssetManager shared] fetchRecentsAssetCollection:^(LXAssetCollection * _Nonnull assetCollection) {
                NSLog(@"-=-=-=-=-=-=====%@",assetCollection.title);
            }];
    
            [[LXAssetManager shared] fetchAllAssetCollections:^(NSArray<LXAssetCollection *> * _Nonnull assetCollections) {
                
                
                [assetCollections enumerateObjectsUsingBlock:^(LXAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                    [obj fetchAllAssets:^(NSArray<LXAssetItem *> * _Nonnull assetItems) {
                        [assetItems enumerateObjectsUsingBlock:^(LXAssetItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            [obj fetchImage:LXAssetImageTypeThumbnail handler:^(UIImage * _Nullable image) {
//                                NSLog(@"===-=--=============%@",image);
                            }];
                            [obj fetchImage:LXAssetImageTypeThumbnail handler:^(UIImage * _Nullable image) {
    //                                NSLog(@"===-=--=============%@",image);
                            }];
                        }];

//                        [obj sortAllAssetsWithAscending:YES];
                    }];

//                    NSLog(@"-=-=-=-=-=-====%@==%@==%ld",obj.title, obj.assetCollection.localIdentifier, obj.assetCount);

            }];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//
    [LXAssetSave saveImageToassetWithImage:[UIImage imageNamed:@"rt"] assetCollectionTitle:@"你好" success:^{
        NSLog(@"===图片===保存成功");

    } fail:^(NSString * _Nonnull error) {
        NSLog(@"=====%@",error);
    }];


//    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"ll" ofType:@"mp4"];
//    NSURL *url = [NSURL fileURLWithPath:filePath];
//    [LXAssetSave saveVideoToassetWithUrl:url assetCollectionTitle:PROJECT_NAME success:^{
//        NSLog(@"===视频===保存成功");
//
//    } fail:^(NSString * _Nonnull error) {
//        NSLog(@"=====%@",error);
//
//    }];
        
//    [LXAuthorManager checkAuthorization:LXAuthorizationTypePhoto
//                                    callBack:^(BOOL isPass) {
//        NSLog(@"===========%d",isPass);
//    }];
    
}

@end
