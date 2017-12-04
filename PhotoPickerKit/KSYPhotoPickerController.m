//
//  KSYPhotoPickerController.m
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2017/12/1.
//  Copyright © 2017年 ksyun.com. All rights reserved.
//

#import "KSYPhotoPickerController.h"
#import "KSYAlbumViewController.h"

#import "KSYPhotoManager.h"
#import "KSYPhotoPickerDefines.h"

@interface KSYPhotoPickerController ()

@end

@implementation KSYPhotoPickerController

- (instancetype)init{
    self = [super init];
    if (self) {
        self = [self initWithDelegate:nil];
    }
    return self;
}

- (instancetype)initWithDelegate:(id <KSYPhotoPickerControllerDelegate>) delegate{
    NSString *nib = NSStringFromClass([KSYAlbumViewController class]);
    //内部 root 控制器
    KSYAlbumViewController *albumPickerVC = [[KSYAlbumViewController alloc] initWithNibName:nib bundle:nil];
    self = [super initWithRootViewController:albumPickerVC];
    if (self) {
        self.pickerDelegate = delegate;
        [self configDefaultSetting]; //默认配置
        [self pushPhotoPickerVCWhenAuthed];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark -
#pragma mark - private methods 私有方法

- (void)configDefaultSetting{
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self configNavigationAppearance];
}

- (void)configNavigationAppearance{
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    if (self.navigationBarTitleColor) {
        textAttrs[NSForegroundColorAttributeName] = self.navigationBarTitleColor;
    } else {
        textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    }
    self.navigationBar.titleTextAttributes = textAttrs;
    
    if (self.navigationBarBgColor) {
        self.navigationBar.barTintColor = self.navigationBarBgColor;
    } else {
        self.navigationBar.barTintColor = kKSYPPKColor(48, 46, 47);
    }
}

- (void)pushPhotoPickerVCWhenAuthed{
    if (![[KSYPhotoManager defaultManager] authorizationStatusAuthorized]) {
        //授权失败
        NSLog(@"授权失败");
    } else {
        NSLog(@"授权成功");
        
    }
}

#pragma mark -
#pragma mark - public methods 公有方法
#pragma mark -
#pragma mark - override methods 复写方法
#pragma mark -
#pragma mark - getters and setters 设置器和访问器
- (void)setNavigationBarBgColor:(UIColor *)navigationBarBgColor{
    _navigationBarBgColor = navigationBarBgColor;
    [self configNavigationAppearance];
}

- (void)setNavigationBarTitleColor:(UIColor *)navigationBarTitleColor{
    _navigationBarTitleColor = navigationBarTitleColor;
    [self configNavigationAppearance];
}

#pragma mark -
#pragma mark - UITableViewDelegate
#pragma mark -
#pragma mark - CustomDelegate 自定义的代理
#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
#pragma mark -
#pragma mark - life cycle 视图的生命周期
#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
