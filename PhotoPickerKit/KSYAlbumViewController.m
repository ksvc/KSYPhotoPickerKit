//
//  KSYAlbumViewController.m
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2017/12/1.
//  Copyright © 2017年 ksyun.com. All rights reserved.
//

#import "KSYAlbumViewController.h"
#import "KSYPhotoPickerController.h"
#import "KSYPhotoManager.h"

@interface KSYAlbumViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView    *tableView;
@property (nonatomic, strong) NSMutableArray *albums;
@property (nonatomic, assign) BOOL           isFirstAppear; //显示返回按钮
@end

@implementation KSYAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configAlbumVC];
}
#pragma mark -
#pragma mark - private methods 私有方法
- (void)configAlbumVC{
    self.isFirstAppear = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self.photoPickerNC action:@selector(cancelButtonClick)];
    
}

- (void)configSubviews{
    //配置 tableview
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __weak KSYAlbumViewController *weakSelf = self;
        
        [[KSYPhotoManager defaultManager] getAllAlbums:self.photoPickerNC.allowPickingPhoto allowPickingImage:self.photoPickerNC.allowPickingVideo completion:^(NSArray<KSYAlbumModel *> *models) {
            __strong KSYAlbumViewController *strongSelf = weakSelf;
            strongSelf.albums = [NSMutableArray arrayWithArray:models];
            for (KSYAlbumModel *albumModel in strongSelf.albums) {
                albumModel.selectedModels = strongSelf.photoPickerNC.selectedModels;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.tableView) {
                    strongSelf.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
                    strongSelf.tableView.rowHeight = 70;
                    strongSelf.tableView.tableFooterView = [[UIView alloc] init];
                    strongSelf.tableView.dataSource = self;
                    strongSelf.tableView.delegate = self;
                    [strongSelf.tableView registerNib:[UINib nibWithNibName:@"KSYAlbumCell" bundle:nil] forCellReuseIdentifier:@"KSYAlbumCell"];
                    [strongSelf.view addSubview:strongSelf.tableView];
                } else {
                    [strongSelf.tableView reloadData];
                }
            });
        }];
    });
}

#pragma mark -
#pragma mark - public methods 公有方法
#pragma mark -
#pragma mark - override methods 复写方法
#pragma mark -
#pragma mark - getters and setters 设置器和访问器
- (KSYPhotoPickerController *)photoPickerNC{
    return (KSYPhotoPickerController *)self.navigationController;
}
#pragma mark -
#pragma mark - UITableViewDelegate
#pragma mark -
#pragma mark - CustomDelegate 自定义的代理
#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
#pragma mark -
#pragma mark - life cycle 视图的生命周期
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.photoPickerNC.allowPickingPhoto) {
        self.navigationItem.title = @"图片";
    } else if (self.photoPickerNC.allowPickingVideo) {
        self.navigationItem.title = @"视频";
    }
    
    
    if (self.isFirstAppear) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.isFirstAppear = NO;
    }
    
    [self configSubviews];
}

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
