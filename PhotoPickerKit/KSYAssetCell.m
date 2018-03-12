//
//  KSYAssetCell.m
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2018/3/8.
//  Copyright © 2018年 ksyun.com. All rights reserved.
//

#import "KSYAssetCell.h"


#import "KSYAlbumModel.h"
#import "KSYProgressView.h"
#import "NSBundle+KSYPhotoPicker.h"
#import "KSYPhotoPickerDefines.h"
#import "KSYPhotoManager.h"

#import "NSBundle+KSYPhotoPicker.h"

@interface KSYAssetCell ()

@property (weak, nonatomic) IBOutlet UIImageView     *imageView;     // 照片
@property (weak, nonatomic) IBOutlet UIImageView     *selectImageView;
@property (weak, nonatomic) IBOutlet UIView          *bottomView;
@property (weak, nonatomic) IBOutlet UILabel         *timeLength;
@property (weak, nonatomic) IBOutlet UIImageView     *videoImgView;
@property (weak, nonatomic) IBOutlet KSYProgressView *progressView;

@property (nonatomic, assign) int32_t bigImageRequestID;
@end

@implementation KSYAssetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    
    self.bottomView.backgroundColor = kKSYPPKRGBA(0, 0, 0, 0.8);
    self.timeLength.font = [UIFont boldSystemFontOfSize:11];
    self.timeLength.textColor = [UIColor whiteColor];
    self.timeLength.textAlignment = NSTextAlignmentRight;
    
}

#pragma mark -
#pragma mark - private methods 私有方法
- (void)fetchBigImage {
    self.bigImageRequestID = [[KSYPhotoManager defaultManager] getPhotoWithAsset:self.model.asset photoWidth:self.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (_progressView) { [self hideProgressView]; }
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        if (self.model.isSelected) {
            progress = progress > 0.02 ? progress : 0.02;;
            self.progressView.progress = progress;
            self.progressView.hidden = NO;
            self.imageView.alpha = 0.4;
            if (progress >= 1) {
                [self hideProgressView];
            }
        } else {
            *stop = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    } networkAccessAllowed:YES];
}
- (void)hideProgressView {
    self.progressView.hidden = YES;
    self.imageView.alpha = 1.0;
}
#pragma mark -
#pragma mark - public methods 公有方法
#pragma mark -
#pragma mark - override methods 复写方法
- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes{
    
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.contentView);
        make.height.equalTo(@17);
    }];
    
    [self.selectPhotoButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.contentView);
        make.width.height.equalTo(@44);
    }];
    
    [self.selectImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.contentView);
        make.width.height.equalTo(@27);
    }];
    
    [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.equalTo(self).multipliedBy(0.5);
    }];
    
    [self.videoImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView.mas_left).offset(8);
        make.top.equalTo(self.bottomView.mas_top);
        make.width.height.equalTo(@17);
    }];
    
    [self.timeLength mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.videoImgView.mas_right);
        make.top.equalTo(self.bottomView.mas_top);
        make.right.equalTo(self.bottomView.mas_right).offset(-5);
        make.height.equalTo(@17);
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.videoImgView.image == nil) {
        self.videoImgView.image = [UIImage imageNamedFromMyBundle:@"VideoSendIcon"];
    }
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
   [super layoutSublayersOfLayer:layer];
}
#pragma mark -
#pragma mark - getters and setters 设置器和访问器
- (void)setModel:(KSYAssetModel *)model{
    _model = model;
    self.representedAssetIdentifier = model.asset.localIdentifier;
    int32_t imageRequestID = [[KSYPhotoManager defaultManager] getPhotoWithAsset:model.asset photoWidth:self.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        self.progressView.hidden = YES;
        self.imageView.alpha = 1.0;
        if ([self.representedAssetIdentifier isEqualToString:model.asset.localIdentifier]) {
            self.imageView.image = photo;
        } else {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) { self.imageRequestID = 0; }
        
    } progressHandler:nil networkAccessAllowed:NO];
    
    self.imageRequestID = imageRequestID;
    self.selectPhotoButton.selected = model.isSelected;
    
    self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamedFromMyBundle:@"photo_sel_photoPickerVc"]:[UIImage imageNamedFromMyBundle:@"photo_def_photoPickerVc"];
    self.type = (NSInteger)model.type;
    
    // 如果用户选中了该图片，提前获取一下大图
    if (model.isSelected) {
        [self fetchBigImage];
    }
    [self setNeedsLayout];
}

- (void)setShowSelectBtn:(BOOL)showSelectBtn{
    _showSelectBtn = showSelectBtn;
    if (!self.selectPhotoButton.hidden) {
        self.selectPhotoButton.hidden = !showSelectBtn;
    }
    if (!self.selectImageView.hidden) {
        self.selectImageView.hidden = !showSelectBtn;
    }
}

- (void)setType:(KSYAssetCellType)type {
    _type = type;
    if (type == KSYAssetCellTypePhoto ||
        type == KSYAssetCellTypeLivePhoto ||
        (type == KSYAssetCellTypePhotoGif && !self.allowPickingGif) || self.allowPickingMultipleVideo) {
        _selectImageView.hidden = NO;
        _selectPhotoButton.hidden = NO;
        _bottomView.hidden = YES;
    } else { // Video of Gif
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
    }
    
    if (type == KSYAssetCellTypeVideo) {
        self.bottomView.hidden = NO;
        self.timeLength.text = _model.timeLength;
        self.videoImgView.hidden = NO;
        _timeLength.textAlignment = NSTextAlignmentRight;
    } else if (type == KSYAssetCellTypePhotoGif && self.allowPickingGif) {
        self.bottomView.hidden = NO;
        self.timeLength.text = @"GIF";
        self.videoImgView.hidden = YES;
        _timeLength.textAlignment = NSTextAlignmentLeft;
    }
}
#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
- (IBAction)selectPhotoButtonClick:(UIButton *)sender {
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(sender.isSelected);
    }
    self.selectImageView.image = sender.isSelected ? [UIImage imageNamedFromMyBundle:@"photo_sel_photoPickerVc"]:[UIImage imageNamedFromMyBundle:@"photo_def_photoPickerVc"];
    if (sender.isSelected) {
        [UIView showOscillatoryAnimationWithLayer:self.selectImageView.layer type:KSYOscillatoryAnimationToBigger];
        // 用户选中了该图片，提前获取一下大图
        [self fetchBigImage];
    } else { // 取消选中，取消大图的获取
        if (_bigImageRequestID && _progressView) {
            [[PHImageManager defaultManager] cancelImageRequest:_bigImageRequestID];
            [self hideProgressView];
        }
    }
}


@end
