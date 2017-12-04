//
//  KSYPhotoPickerControllerDelegate.h
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2017/12/1.
//  Copyright © 2017年 ksyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@class KSYPhotoPickerController;
@class KSYAssetModel;
@protocol KSYPhotoPickerControllerDelegate <NSObject>

@optional

/**
 适配选择完成返回所有装有视频 PHAsset 的 模型对象

 @param picker 选择器
 @param models 所有 model
 */
- (void)photoPickerController:(KSYPhotoPickerController *)picker
       didFinishPickingVideos:(NSArray<KSYAssetModel *> *)models;

@end
