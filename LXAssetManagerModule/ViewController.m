//
//  ViewController.m
//  LXAssetManagerModule
//
//  Created by 李响 on 2021/2/23.
//

#import "ViewController.h"
#import <LXAssetSave.h>
#import <LXAuthorManager.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

//    [LXAssetSave saveImageToassetWithImage:[UIImage imageNamed:@"rt"] assetCollectionTitle:@"xlee" success:^{
//        NSLog(@"===图片===保存成功");
//
//    } fail:^(NSString * _Nonnull error) {
//        NSLog(@"=====%@",error);
//    }];

    
//    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"ll" ofType:@"mp4"];
//    NSURL *url = [NSURL fileURLWithPath:filePath];
//    [LXAssetSave saveVideoToassetWithUrl:url assetCollectionTitle:nil success:^{
//        NSLog(@"===视频===保存成功");
//
//    } fail:^(NSString * _Nonnull error) {
//        NSLog(@"=====%@",error);
//
//    }];
    
    [LXAssetAuthorization checkAuthorization:LXAuthorizationTypePhoto
                                    callBack:^(BOOL isPass) {
        NSLog(@"===========%d",isPass);
    }];
    
}

@end
