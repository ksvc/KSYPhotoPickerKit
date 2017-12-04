//
//  KSYPhotoManager.m
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2017/11/29.
//  Copyright © 2017年 ksyun.com. All rights reserved.
//

#import "KSYPhotoManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

static BOOL kiOS9Later;
static CGFloat kKSYScreenScale;

@interface KSYPhotoManager ()

@property(nonatomic, strong) ALAssetsLibrary *assetLibrary; //保存相册用到之前图片相关类

@end

@implementation KSYPhotoManager

+ (instancetype)defaultManager{
    static KSYPhotoManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.cachingImageManager = [[PHCachingImageManager alloc] init];
        kiOS9Later = ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f);
        //如果scale在plus真机上取到3.0，内存会增大特别多。故这里写死成2.0
        kKSYScreenScale = 2.0;
    });
    return instance;
}

#pragma mark -
#pragma mark - PHPhotoLibrary Authorization 本地相册权限检测相关
+ (NSInteger)authorizationStatus {
    return [PHPhotoLibrary authorizationStatus];
}

- (BOOL)authorizationStatusAuthorized{
    return [self.class authorizationStatus] == 3;
}

- (void)requestAuthorization:(void (^)(BOOL authorization))completion {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == 3) { completion(YES); }
    }];
}

#pragma mark -
#pragma mark - Picking Images/Videos 相册选择图片/视频相关
- (void)getAllAlbums:(BOOL)allowPickingVideo
   allowPickingImage:(BOOL)allowPickingImage
          completion:(void (^)(NSArray< KSYAlbumModel *> *models))completion{
    NSMutableArray *albumArr = [NSMutableArray array];
    //抓取条件哈哈
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = [self cfgPredicateWithAllowImage:allowPickingImage allowVideo:allowPickingVideo];
    
    if (!_sortAscendingByModificationDate) {
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
    }
    
    //我的照片流 1.6.10重新加入..
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    //智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //个人收藏
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    //同步
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    //共享 来自 iCloud
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *allAlbums = @[myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            if (![collection isKindOfClass:[PHAssetCollection class]]) { continue; }
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (fetchResult.count < 1) { continue; }
            if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"]){ continue; }
            
            if ([self isCameraRollAlbum:collection.localizedTitle]) {
                KSYAlbumModel *model = [[KSYAlbumModel alloc]  initWithFetchResult:fetchResult albumName:collection.localizedTitle];
                [albumArr insertObject:model atIndex:0];
            } else {
                KSYAlbumModel *model = [[KSYAlbumModel alloc]  initWithFetchResult:fetchResult albumName:collection.localizedTitle];
                [albumArr addObject:model];
            }
        }
    }
    //找出后回调
    if (completion && albumArr.count > 0) { completion(albumArr); }
}

- (void)getAssetsFromFetchResult:(PHFetchResult *)fetchResult
               allowPickingVideo:(BOOL)allowPickingVideo
               allowPickingImage:(BOOL)allowPickingImage
                      completion:(void (^)(NSArray<KSYAssetModel *> *models))completion{
    NSMutableArray *photoArr = [NSMutableArray array];
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KSYAssetModel *model = [self assetModelWithAsset:obj allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
        if (model) {
            [photoArr addObject:model];
        }
    }];
    
    if (completion) { completion(photoArr); }
}

- (void)getAssetFromFetchResult:(PHFetchResult *)result
                        atIndex:(NSInteger)index
              allowPickingVideo:(BOOL)allowPickingVideo
              allowPickingImage:(BOOL)allowPickingImage
                     completion:(void (^)(KSYAssetModel *model))completion{
    PHAsset *asset;
    @try {
        asset = result[index];
    }
    @catch (NSException* e) {
        if (completion) { completion(nil); };
        return;
    }
    KSYAssetModel *model = [self assetModelWithAsset:asset allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
    if (completion) { completion(model); };
}

- (void)getPhotoWithAsset:(PHAsset *)asset
           thumbnailImage:(BOOL)isThumbnail
               photoWidth:(CGFloat)photoWidth
               completion:(void (^)(UIImage *, NSDictionary *))completion{
    PHAsset *phAsset = (PHAsset *)asset;
    CGSize size;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    //默认加载 icloud 的图片 需要开启网络下载
    options.networkAccessAllowed = YES;
    PHImageContentMode contentMode = PHImageContentModeAspectFit;
    if (isThumbnail) {
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat dimension = photoWidth;
        size = CGSizeMake(dimension * scale, dimension * scale);
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        contentMode = PHImageContentModeAspectFill;
    } else {
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            
        };
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        CGFloat multiple = [UIScreen mainScreen].scale;
        CGFloat pixelWidth = photoWidth * multiple;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        size = CGSizeMake(pixelWidth, pixelHeight);
        contentMode = PHImageContentModeAspectFit;
    }
    
    
    if (phAsset.representsBurst) {
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
        fetchOptions.includeAllBurstAssets = YES;
        PHFetchResult *burstSequence = [PHAsset fetchAssetsWithBurstIdentifier:phAsset.burstIdentifier options:fetchOptions];
        phAsset = burstSequence.firstObject;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
    }
    
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:size contentMode:contentMode options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinished = ![[info objectForKey:PHImageCancelledKey] boolValue]
        && ![info objectForKey:PHImageErrorKey]
        && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (completion) {
            completion(result,info);
        }
    }];
}

- (void)getPhotoWithAsset:(PHAsset *)asset
           thumbnailWidth:(CGFloat)width
               completion:(void (^)(UIImage *image, UIImage *thumbnailImage, NSDictionary *info))completion{
    PHAsset *phAsset = (PHAsset *)asset;
    CGSize size = CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight);
    
    //基于宽度按照比例系数算出高度
    CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
    CGFloat pixelWidth = width;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    CGSize thumbnailSize = CGSizeMake(pixelWidth, pixelHeight);
    
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:phAsset
                                               targetSize:size
                                              contentMode:PHImageContentModeDefault
                                                  options:requestOptions
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (completion) {
            @autoreleasepool {
                UIImage *thumbnailImage = [self imageWithImage:result scaledToSize:thumbnailSize];
                completion(result, thumbnailImage, info);
            }
        }
    }];
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset
                           photoWidth:(CGFloat)photoWidth
                           completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion
                      progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                 networkAccessAllowed:(BOOL)networkAccessAllowed{
    CGSize imageSize;
    PHAsset *phAsset = (PHAsset *)asset;
    CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
    CGFloat pixelWidth = photoWidth * kKSYScreenScale;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    imageSize = CGSizeMake(pixelWidth, pixelHeight);
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            if (completion) {
                completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            }
        }
        
    }];
    return imageRequestID;
    
}

- (void)getPostImageWithAlbumModel:(KSYAlbumModel *)model
                        completion:(void (^)(UIImage *postImage))completion{
    PHAsset *asset = [model.result lastObject];
    if (!self.sortAscendingByModificationDate) {
        asset = [model.result firstObject];
    }
    
    [self getPhotoWithAsset:asset
                 photoWidth:80
                 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion) { completion(photo); }
    } progressHandler:nil networkAccessAllowed:YES];
    
}

- (void)getCameraRollAssetWithallowPickingVideo:(BOOL)allowPickingVideo
                              allowPickingImage:(BOOL)allowPickingImage
                                     completion:(void (^)(NSArray<KSYAssetModel *> *models, NSInteger videoCount))completion{
    NSInteger videoCount;
    __block NSArray *photoArray;
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    option.predicate = [self cfgPredicateWithAllowImage:allowPickingImage allowVideo:allowPickingVideo];
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    PHFetchResult *fetchResult =[PHAsset fetchAssetsInAssetCollection:cameraRoll options:option];
    videoCount = [fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
    [self getAssetsFromFetchResult:fetchResult allowPickingVideo:YES allowPickingImage:YES completion:^(NSArray<KSYAssetModel *> *models) {
        photoArray = (NSArray *)models;
    }];
    if (completion) { completion(photoArray,videoCount); }
}

- (void)getVideoWithAsset:(PHAsset *)asset
               completion:(void (^)(AVAsset * avAsset, NSDictionary * info))completion{
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        
    };
    PHAsset *phAsset = (PHAsset *)asset;
    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(asset, nil);
        });
    }];
}

- (void)saveVideoAtUrl:(NSURL *)videoURL
           toAlbumName:(NSString *)albumName
            completion:(void (^)(NSError *error))completion{
    if (@available(iOS 9.0, *)) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            //            options.shouldMoveFile = YES;
            [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (success && completion) {
                    NSLog(@"PHPhotoLibrary保存成功");
                    completion(nil);
                } else if (error) {
                    NSLog(@"iOS9之后,保存视频失败:%@",error.localizedDescription);
                    if (completion){ completion(error); }
                }
            });
        }];
    } else {
        [self.assetLibrary writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"iOS9之前,保存视频失败:%@",error.localizedDescription);
                if (completion) { completion(error); }
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSLog(@"ALAssetsLibrary保存成功");
                    if (completion) { completion(nil); }
                });
            }
        }];
    }
}

#pragma mark -
#pragma mark - helper 相关工具代码
- (NSPredicate *)cfgPredicateWithAllowImage:(BOOL)image allowVideo:(BOOL)video{
    NSPredicate *predicate;
    
    NSString *imageFormat = [NSString stringWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    NSString *videoFormat = [NSString stringWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    
    if (image && !video) {
        predicate = [NSPredicate predicateWithFormat:imageFormat];
    } else if (video && !image) {
        predicate = [NSPredicate predicateWithFormat:videoFormat];
    } else if (video && image) {
        NSString *imageAndVideo = [NSString stringWithFormat:@"%@ || (%@)", videoFormat, imageFormat];
        predicate = [NSPredicate predicateWithFormat:imageAndVideo];
    }
    return predicate;
}

//check 是否是相机胶卷
- (BOOL)isCameraRollAlbum:(NSString *)albumName {
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    
    if (version >= 800 && version <= 802) {
        return [albumName isEqualToString:@"最近添加"]
        || [albumName isEqualToString:@"Recently Added"];
    } else {
        return [albumName isEqualToString:@"Camera Roll"]
        || [albumName isEqualToString:@"相机胶卷"]
        || [albumName isEqualToString:@"所有照片"]
        || [albumName isEqualToString:@"All Photos"];
    }
}


- (KSYAssetModel *)assetModelWithAsset:(id)asset allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage {
    KSYAssetModel *model = nil;
    KSYAssetModelMediaType type = KSYAssetModelMediaTypePhoto;
    
    PHAsset *phAsset = (PHAsset *)asset;
    if (phAsset.mediaType == PHAssetMediaTypeVideo){ type = KSYAssetModelMediaTypeVideo; }
    else if (phAsset.mediaType == PHAssetMediaTypeAudio){ type = KSYAssetModelMediaTypeAudio; }
    else if (phAsset.mediaType == PHAssetMediaTypeImage) {
        if ([[phAsset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
            type = KSYAssetModelMediaTypePhotoGif;
        }
    }
    if (!allowPickingImage && type == KSYAssetModelMediaTypePhotoGif) { return nil; };
    if (self.hideWhenCanNotSelect) {
        if (![self isPhotoSelectableWithAsset:phAsset]) { return nil; }
    }
    model = [KSYAssetModel modelWithAsset:asset type:type];
    return model;
}

- (BOOL)isPhotoSelectableWithAsset:(id)asset {
    PHAsset *phAsset = (PHAsset *)asset;
    CGSize photoSize = CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight);
    if (self.minPhotoWidthSelectable > photoSize.width || self.minPhotoHeightSelectable > photoSize.height) {
        return NO;
    }
    return YES;
}

//为了显示缩略图这里使用画笔画出原始图片并返回 这样节省内存 后续考虑提供更多接口
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
