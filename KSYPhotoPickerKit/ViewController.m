//
//  ViewController.m
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2017/11/28.
//  Copyright © 2017年 ksyun.com. All rights reserved.
//

#import "ViewController.h"
#import "KSYPhotoPickerController.h"


@interface ViewController () <KSYPhotoPickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark -
#pragma mark - private methods 私有方法
#pragma mark -
#pragma mark - public methods 公有方法
#pragma mark -
#pragma mark - override methods 复写方法
#pragma mark -
#pragma mark - getters and setters 设置器和访问器
#pragma mark -
#pragma mark - UITableViewDelegate
#pragma mark -
#pragma mark - CustomDelegate 自定义的代理
- (void)ksyPhotoPickerController:(KSYPhotoPickerController *)picker
          didFinishPickingVideos:(NSArray *)phassets{
    NSLog(@"勾选所有的:%@",phassets);
}

- (void)ksyPhotoPickerController:(KSYPhotoPickerController *)picker
               singleSelectModel:(KSYAssetModel *)model{
    NSLog(@"%@",model);
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}
#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等

- (IBAction)presentAction:(UIButton *)sender {
    KSYPhotoPickerController *picker = [[KSYPhotoPickerController alloc] initWithDelegate:self];
    picker.pushPhotoPickerVC = YES;
    picker.allowPickingVideo = YES;
    picker.allowPickingPhoto = NO;
    picker.allowPickingMultipleVideo = NO;
    [self presentViewController:picker animated:YES completion:nil];
}
#pragma mark -
#pragma mark - life cycle 视图的生命周期
#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
