//
//  KSYAlbumModel.h
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2017/11/29.
//  Copyright © 2017年 ksyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//---------------------------------------------------
//---------------------------------------------------
//---------------------------------------------------

typedef NS_ENUM(NSInteger, KSYAssetModelMediaType) {
    KSYAssetModelMediaTypePhoto = 0,
    KSYAssetModelMediaTypeLivePhoto,
    KSYAssetModelMediaTypePhotoGif,
    KSYAssetModelMediaTypeVideo,
    KSYAssetModelMediaTypeAudio,
    KSYAssetModelMediaTypeToRecod
    
};

@class PHAsset;
//相册图片/视频等模型
@interface KSYAssetModel :NSObject
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) KSYAssetModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;
@property (nonatomic, assign) NSInteger assetDuration;
@property (nonatomic, strong) UIImage *thumbnailImage;


/**
 基于 asset 和 type 生成 AssetModel

 @param asset 相册媒体资源对象
 @param type  媒体类型
 @return 当前实例
 */
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(KSYAssetModelMediaType)type;
@end

//---------------------------------------------------
//---------------------------------------------------
//---------------------------------------------------

@class PHFetchResult;
//相册模型
@interface KSYAlbumModel : NSObject
@property (nonatomic, strong) NSString      *albumName;//相册名称
@property (nonatomic, assign) NSInteger     assetsCount;//相册里内容数量
@property (nonatomic, strong) PHFetchResult *result;///< PHFetchResult<PHAsset> >


@property (nonatomic, strong) NSArray       *models;
@property (nonatomic, strong) NSArray       *selectedModels;
@property (nonatomic, assign) NSUInteger selectedCount;

- (instancetype)initWithFetchResult:(PHFetchResult *)result albumName:(NSString *)albumName;
@end
