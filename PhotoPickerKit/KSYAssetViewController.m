//
//  KSYAssetViewController.m
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2018/3/7.
//  Copyright © 2018年 ksyun.com. All rights reserved.
//

#import "KSYAssetViewController.h"
#import "KSYPhotoPickerController.h"
#import "KSYPhotoManager.h"
#import "KSYAssetCell.h"
#import "KSYPhotoPickerControllerDelegate.h"
#import "NSBundle+KSYPhotoPicker.h"
static CGFloat itemMargin = 5;  //collectionview 上左下右间距
@interface KSYAssetViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UIImagePickerControllerDelegate,
UIAlertViewDelegate
>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView           *bottomToolBar;
@property (weak, nonatomic) IBOutlet UIButton         *doneButton;
@property (weak, nonatomic) IBOutlet UIImageView      *numberImageView;
@property (weak, nonatomic) IBOutlet UILabel          *numberLabel;

@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (assign, nonatomic) CGFloat                    offsetItemCount;
@property (strong, nonatomic) NSMutableArray             *models;

@end

@implementation KSYAssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.model.albumName;
    
    //给导航控制器加返回事件
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:[self photoPickerNC] action:@selector(cancelButtonClick)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [self.view updateConstraintsIfNeeded];
}
#pragma mark -
#pragma mark - life cycle 视图的生命周期
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.models == nil) { [self fetchAssetModels]; }
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

#pragma mark -
#pragma mark - private methods 私有方法
- (void)fetchAssetModels {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[KSYPhotoManager defaultManager] getAssetsFromFetchResult:self.model.result allowPickingVideo:[self photoPickerNC].allowPickingVideo allowPickingImage:[self photoPickerNC].allowPickingPhoto completion:^(NSArray<KSYAssetModel *> *models) {
            self.models = [NSMutableArray arrayWithArray:models];
            [self initSubviews];
        }];
    });
}

- (void)initSubviews {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkSelectedModels];
        [self configCollectionView];
        
        [self configBottomToolBar];
        [self.collectionView reloadData];
    });
}

- (void)checkSelectedModels {
    for (KSYAssetModel *model in self.models) {
        model.isSelected = NO;
        NSMutableArray *selectedAssets = [NSMutableArray array];
        
        for (KSYAssetModel *model in [self photoPickerNC].selectedModels) {
            [selectedAssets addObject:model.asset];
        }
        if ([selectedAssets containsObject:model.asset]) {
            model.isSelected = YES;
        }
    }
}

- (void)configCollectionView {
    
    self.layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWH = ([UIScreen mainScreen].bounds.size.width - (5 + 1) * itemMargin) / 4;
    self.layout.itemSize = CGSizeMake(itemWH, itemWH);
    self.layout.minimumInteritemSpacing = itemMargin;
    self.layout.minimumLineSpacing = itemMargin;
    
    self.collectionView.collectionViewLayout = self.layout;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.alwaysBounceHorizontal = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(itemMargin, itemMargin, itemMargin, itemMargin);
    
    self.collectionView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), ((self.model.assetsCount + 4 - 1) / 4) * CGRectGetWidth(self.view.frame));
    UINib *nib = [UINib nibWithNibName:@"KSYAssetCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"KSYAssetCell"];
}

- (void)configBottomToolBar{
    self.bottomToolBar.backgroundColor = kKSYPPKRGBA(253, 253, 253, 1.0);
    self.numberLabel.text = [NSString stringWithFormat:@"%zd",[self photoPickerNC].selectedModels.count];
    self.numberLabel.hidden = self.photoPickerNC.selectedModels.count <= 0;
    
    self.numberImageView.image  = [UIImage imageNamedFromMyBundle:@"photo_number_icon"];
    self.numberImageView.hidden = [self photoPickerNC].selectedModels.count <= 0;
    self.numberImageView.backgroundColor = [UIColor clearColor];
    

    [self.doneButton setTitleColor:kKSYPPKRGBA(83, 179, 17, 1.0) forState:UIControlStateNormal];
    [self.doneButton setTitleColor:kKSYPPKRGBA(83, 179, 17, 0.5) forState:UIControlStateDisabled];
}

/// Scale image / 缩放图片
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width < size.width) {
        return image;
    }
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)refreshBottomToolBarStatus {
    self.doneButton.enabled = [self photoPickerNC].selectedModels.count > 0;
    
    self.numberImageView.hidden = [self photoPickerNC].selectedModels.count <= 0;
    self.numberLabel.hidden = [self photoPickerNC].selectedModels.count <= 0;
    self.numberLabel.text = [NSString stringWithFormat:@"%zd",[self photoPickerNC].selectedModels.count];
}
#pragma mark -
#pragma mark - override methods 复写方法
- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)updateViewConstraints{
    [super updateViewConstraints];
    
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomToolBar.mas_top);
    }];
    
    CGFloat toolBarHeight = [KSYCommonTools ksy_isIPhoneX] ? 50 + (83 - 49) : 50;
    [self.bottomToolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom);
        make.height.equalTo(@(toolBarHeight));
    }];
    
    [self.doneButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomToolBar.mas_top).offset(5);
        make.right.equalTo(self.bottomToolBar.mas_right).offset(-12);
        make.height.equalTo(@33);
    }];
    
    
    [self.numberLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.doneButton.mas_centerY);
        make.right.equalTo(self.doneButton.mas_left);
        make.width.height.equalTo(@30);
    }];
    
    [self.numberImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.numberLabel);
    }];
    
}
#pragma mark -
#pragma mark - getters and setters 设置器和访问器
- (KSYPhotoPickerController *)photoPickerNC{
    return (KSYPhotoPickerController *)self.navigationController;
}
#pragma mark -
#pragma mark - UITableViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // the cell dipaly photo or video / 展示照片或视频的cell
    KSYAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KSYAssetCell" forIndexPath:indexPath];
    cell.allowPickingMultipleVideo = self.photoPickerNC.allowPickingMultipleVideo;
    
    cell.showSelectBtn = [self photoPickerNC].allowPickingMultipleVideo;
    KSYAssetModel *model = self.models[indexPath.row];
    
    cell.allowPickingGif = self.photoPickerNC.allowPickingGif;
    cell.model = model;    
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    __weak typeof(self.numberImageView.layer) weakLayer = self.numberImageView.layer;
    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
        __strong typeof(weakCell) strongCell = weakCell;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        __strong typeof(weakLayer) strongLayer = weakLayer;
        // 1. cancel select / 取消选择
        if (isSelected) {
            strongCell.selectPhotoButton.selected = NO;
            model.isSelected = NO;
            NSArray *selectedModels = [NSArray arrayWithArray:[strongSelf photoPickerNC].selectedModels];
            for (KSYAssetModel *model_item in selectedModels) {
                if ([model.asset.localIdentifier isEqualToString:model_item.asset.localIdentifier]) {
                    [[self photoPickerNC].selectedModels removeObject:model_item];
                    break;
                }
            }
            [strongSelf refreshBottomToolBarStatus];
        } else {
            strongCell.selectPhotoButton.selected = YES;
            model.isSelected = YES;
            [[self photoPickerNC].selectedModels addObject:model];
            [strongSelf refreshBottomToolBarStatus];
        
        }
        [UIView showOscillatoryAnimationWithLayer:strongLayer type:KSYOscillatoryAnimationToSmaller];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // preview phote or video / 预览照片或视频
    KSYAssetModel *model = self.models[indexPath.row];
    if (model.type == KSYAssetModelMediaTypeVideo && ![self photoPickerNC].allowPickingMultipleVideo) {
        if ([self photoPickerNC].selectedModels.count > 0) {
            NSLog(@"Can not choose both video and photo");
        } else {
            //TODO:播放视频
            [self callDelegateSingleSelected:model];
        }
    } else if (model.type == KSYAssetModelMediaTypePhotoGif && [self photoPickerNC].allowPickingGif && ![self photoPickerNC].allowPickingMultipleVideo) {
        if ([self photoPickerNC].selectedModels.count > 0) {
            NSLog(@"Can not choose both photo and GIF");
        } else {
            //TODO:gif 预览
            NSLog(@"gif 预览:功能待完善");
        }
    } else {
        NSLog(@"普通预览:功能待完善");
    }
}

#pragma mark -
#pragma mark - CustomDelegate 自定义的代理
#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
- (void)didChangeStatusBarOrientationNotification:(NSNotification *)noti {
    self.offsetItemCount = self.collectionView.contentOffset.y / (self.layout.itemSize.height + self.layout.minimumLineSpacing);
}

- (IBAction)doneButtonClick:(UIButton *)sender {
    if ([self photoPickerNC].selectedModels.count == 0) {
        NSLog(@"至少需要选择一张");
        return;
    }
    //check min select count
    NSMutableArray *photos = [NSMutableArray array];
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *infoArr = [NSMutableArray array];
    for (NSInteger i = 0; i < [self photoPickerNC].selectedModels.count; i++) {
        [photos addObject:@1];
        [assets addObject:@1];
        [infoArr addObject:@1];
    }
    
    CGFloat itemWH = (CGRectGetWidth([UIScreen mainScreen].bounds) - (5 + 1) * itemMargin) / 4;
    for (NSUInteger i = 0; i < [self photoPickerNC].selectedModels.count; i++) {
        KSYAssetModel *model = self.photoPickerNC.selectedModels[i];
        [[KSYPhotoManager defaultManager] getPhotoWithAsset:model.asset photoWidth:itemWH completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (isDegraded) return;
            if (photo) {
                photo = [self scaleImage:photo toSize:CGSizeMake(828.0, (int)(828.0 * photo.size.height / photo.size.width))];
                [photos replaceObjectAtIndex:i withObject:photo];
            }
            if (info)  [infoArr replaceObjectAtIndex:i withObject:info];
            [assets replaceObjectAtIndex:i withObject:model.asset];
            
            for (id item in photos) {
                if ([item isKindOfClass:[NSNumber class]]) {  return; }
            }
            
            [self didGetAllPhotos:photos assets:assets infoArr:infoArr];
        } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            // 如果图片正在从iCloud同步中,提醒用户
            if (progress < 1) {
                NSLog(@"Synchronizing photos from iCloud");
                return;
            }
        } networkAccessAllowed:YES];
    }
    if ([self photoPickerNC].selectedModels.count <= 0) {
        [self didGetAllPhotos:photos assets:assets infoArr:infoArr];
    }
}

- (void)didGetAllPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infoArr {
    
    if ([self photoPickerNC].autoDismiss) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethodWithPhotos:photos assets:assets infoArr:infoArr];
        }];
    } else {
        [self callDelegateMethodWithPhotos:photos assets:assets infoArr:infoArr];
    }
}

- (void)callDelegateMethodWithPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infoArr {
    
    if ([[self photoPickerNC].pickerDelegate respondsToSelector:@selector(ksyPhotoPickerController:didFinishPickingVideos:)]) {
        [self.photoPickerNC.pickerDelegate ksyPhotoPickerController:self.photoPickerNC didFinishPickingVideos:assets];
    }
}

//单选
- (void)callDelegateSingleSelected:(KSYAssetModel *)model{
    if ([self.photoPickerNC.pickerDelegate respondsToSelector:@selector(ksyPhotoPickerController:singleSelectModel:)]) {
        [self.photoPickerNC.pickerDelegate ksyPhotoPickerController:self.photoPickerNC singleSelectModel:model];
    }
}

#pragma mark -
#pragma mark - public methods 公有方法
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
