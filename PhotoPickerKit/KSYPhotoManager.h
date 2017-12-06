//
//  KSYPhotoManager.h
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2017/11/29.
//  Copyright © 2017年 ksyun.com. All rights reserved.
//  [参考](jieguo)
//  [参考](http://kayosite.com/ios-development-and-detail-of-photo-framework-part-three.html)


#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "KSYAlbumModel.h"

@interface KSYPhotoManager : NSObject

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;
/// Minimum selectable photo width, Default is 0
/// 最小可选中的图片宽度，默认是0，小于这个宽度的图片不可选中
@property (nonatomic, assign) NSInteger             minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger             minPhotoHeightSelectable;
@property (nonatomic, assign) BOOL                  hideWhenCanNotSelect;
/// 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个
@property (nonatomic, assign) BOOL                  sortAscendingByModificationDate;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;


/**
 对外单例接口

 @return 默认对象
 */
+ (instancetype)defaultManager;

//================================================
//=============== 本地授权相关接口 ==================
//================================================
/**
 相册是否授权

 @return Return YES if Authorized 返回YES如果得到了授权
 */
- (BOOL)authorizationStatusAuthorized;

/**
 请求授权

 @param completion 回调
 */
- (void)requestAuthorization:(void (^)(BOOL authorization))completion;


//================================================
//=============== 获取相册图片/视频相关接口 ==========
//================================================


/**
 Get Album 获得相册/时刻数组
 这个方法主要获取的是多少个相册(相册有系统默认+我们自己手动创建+app创建)
 @param allowPickingVideo 是否允许选择视频
 @param allowPickingImage 是否允许选择图片
 @param completion 返回选择的模型
 */
- (void)getAllAlbums:(BOOL)allowPickingVideo
   allowPickingImage:(BOOL)allowPickingImage
          completion:(void (^)(NSArray< KSYAlbumModel *> *models))completion;


/**
 Get Assets 获得Asset数组(这个方法主要获取相册中的资源文件 eg:imags、video、live photo...)
 
 @param fetchResult 资源结果集合
 @param allowPickingVideo 是否允许选择视频
 @param allowPickingImage 是否允许选择图片
 @param completion 选完的回调
 */
- (void)getAssetsFromFetchResult:(PHFetchResult *)fetchResult
               allowPickingVideo:(BOOL)allowPickingVideo
               allowPickingImage:(BOOL)allowPickingImage
                      completion:(void (^)(NSArray<KSYAssetModel *> *models))completion;



/**
 试图获取指定的资源结果集合里某个资源

 @param result 资源结果集合
 @param index 索引
 @param allowPickingVideo 是否允许选择视频
 @param allowPickingImage 是否允许选择图片
 @param completion callback
 */
- (void)getAssetFromFetchResult:(PHFetchResult *)result
                        atIndex:(NSInteger)index
              allowPickingVideo:(BOOL)allowPickingVideo
              allowPickingImage:(BOOL)allowPickingImage
                     completion:(void (^)(KSYAssetModel *model))completion;


/**
 获取具体的资源

 @param asset asset
 @param isThumbnail 是否缩略图
 @param photoWidth 图片宽度(根据宽度基于屏幕scale算高度)
 @param completion 完成回调
 */
- (void)getPhotoWithAsset:(PHAsset *)asset
           thumbnailImage:(BOOL)isThumbnail
               photoWidth:(CGFloat)photoWidth
               completion:(void (^)(UIImage *, NSDictionary *))completion;


/**
 将asset转为image图片

 @param asset asset
 @param width 图片宽度(根据宽度基于屏幕scale算高度)
 @param completion 完成回调
 */
- (void)getPhotoWithAsset:(PHAsset *)asset
           thumbnailWidth:(CGFloat)width
               completion:(void (^)(UIImage *image, UIImage *thumbnailImage, NSDictionary *info))completion;


/**
 将asset转为image图片 带进度设置+iCloud图片

 @param asset asset
 @param photoWidth 图片宽度(根据宽度基于屏幕scale算高度)
 @param completion 完成回调
 @param progressHandler 过程中回调
 @param networkAccessAllowed 是否请求下载 iCloud图片
 @return PHImageRequestID 请求 ID
 */
- (PHImageRequestID)getPhotoWithAsset:(id)asset
                           photoWidth:(CGFloat)photoWidth
                           completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion
                      progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                 networkAccessAllowed:(BOOL)networkAccessAllowed;

/**
 获取相册封面
 */
- (void)getPostImageWithAlbumModel:(KSYAlbumModel *)model
                        completion:(void (^)(UIImage *postImage))completion;



/**
 获取相机胶卷中的资源

 @param allowPickingVideo 是否允许选择视频
 @param allowPickingImage 是否允许选择图片
 @param completion 完成回调
 */
- (void)getCameraRollAssetWithallowPickingVideo:(BOOL)allowPickingVideo
                              allowPickingImage:(BOOL)allowPickingImage
                                     completion:(void (^)(NSArray<KSYAssetModel *> *models, NSInteger videoCount))completion;

/**
 获取视频实例从相册实例中

 @param asset asset
 @param completion 完成回调
 */
- (void)getVideoWithAsset:(PHAsset *)asset
               completion:(void (^)(AVAsset * avAsset, NSDictionary * info))completion;


/**
 获取PHAsset 类型

 @param asset 资源元数据
 @return 类型枚举
 */
- (KSYAssetModelMediaType)getAssetType:(PHAsset *)asset;

/**
 保存视频到相册

 @param videoURL 视频本地 URL
 @param albumName 相册名称
 @param completion 完成回调
 */
- (void)saveVideoAtUrl:(NSURL *)videoURL
           toAlbumName:(NSString *)albumName
            completion:(void (^)(NSError *error))completion;


@end
