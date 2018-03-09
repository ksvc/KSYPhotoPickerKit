//
//  KSYPhotoPickerController.h
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2017/12/1.
//  Copyright © 2017年 ksyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYPhotoPickerControllerDelegate.h"
#import "KSYPhotoPickerDefines.h"
@interface KSYPhotoPickerController : UINavigationController

//默认为YES，如果设置为NO, 选择器将不会自己dismiss
@property (nonatomic, assign) BOOL autoDismiss;
//是否进入到资源选择 默认为NO
@property (nonatomic, assign) BOOL pushPhotoPickerVC;
//是否允许勾选图片 默认为YES
@property (nonatomic, assign) BOOL allowPickingPhoto;
//是否允许勾选视频 默认为YES
@property (nonatomic, assign) BOOL allowPickingVideo;
//Default is NO / 默认为NO，为YES时可以多选视频/gif图片，和照片共享最大可选张数maxImagesCount的限制
@property (nonatomic, assign) BOOL allowPickingMultipleVideo;
/// 默认为NO，如果设置为YES,用户可以选择gif图片
@property (nonatomic, assign) BOOL allowPickingGif;

@property (nonatomic, strong) UIColor *navigationBarBgColor;//导航栏背景颜色
@property (nonatomic, strong) UIColor *navigationBarTitleColor;//导航栏 title 颜色

//用户选中过的图片数组
@property (nonatomic, strong) NSMutableArray                  *selectedAssets;
@property (nonatomic, strong) NSMutableArray<KSYAssetModel *> *selectedModels;


@property (nonatomic, weak  ) id<KSYPhotoPickerControllerDelegate> pickerDelegate;

/**
 初始化图片选择器

 @param delegate 选择器代理
 @return instance
 */
- (instancetype)initWithDelegate:(id <KSYPhotoPickerControllerDelegate>) delegate;


/**
 取消按钮点击方法
 */
- (void)cancelButtonClick;
@end

//------------------------------------------
//---------------工具类 helper---------------
//------------------------------------------

@interface KSYCommonTools : NSObject
+ (BOOL)ksy_isIPhoneX;
+ (CGFloat)ksy_statusBarHeight;
// 获得Info.plist数据字典
+ (NSDictionary *)tz_getInfoDictionary;
@end
