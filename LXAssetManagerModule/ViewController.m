//
//  ViewController.m
//  LXAssetManagerModule
//
//  Created by 李响 on 2021/2/23.
//

#import "ViewController.h"
#import <LXAssetSave.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [LXAssetSave saveImageToassetWithImage:[UIImage imageNamed:@"rt"] assetCollectionTitle:@"xlee" success:^{
        NSLog(@"===图片===保存成功");

    } fail:^(NSString * _Nonnull error) {
        NSLog(@"=====%@",error);
    }];
    
    
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"ll" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    [LXAssetSave saveVideoToassetWithUrl:url assetCollectionTitle:@"xlee" success:^{
        NSLog(@"===视频===保存成功");

    } fail:^(NSString * _Nonnull error) {
        NSLog(@"=====%@",error);

    }];
    
}

@end
