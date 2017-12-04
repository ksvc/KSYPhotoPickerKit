//
//  KSYPhotoPickerController.h
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2017/12/1.
//  Copyright © 2017年 ksyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYPhotoPickerControllerDelegate.h"

@interface KSYPhotoPickerController : UINavigationController

@property (nonatomic, strong) UIColor  *navigationBarBgColor;    //导航栏背景颜色
@property (nonatomic, strong) UIColor  *navigationBarTitleColor; //导航栏 title 颜色

@property (nonatomic, weak  ) id<KSYPhotoPickerControllerDelegate> pickerDelegate;

/**
 初始化图片选择器

 @param delegate 选择器代理
 @return instance
 */
- (instancetype)initWithDelegate:(id <KSYPhotoPickerControllerDelegate>) delegate;

@end
