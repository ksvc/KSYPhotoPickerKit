//
//  KSYPhotoPickerDefines.h
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2017/12/4.
//  Copyright © 2017年 ksyun.com. All rights reserved.
//

#ifndef KSYPhotoPickerDefines_h
#define KSYPhotoPickerDefines_h

#define kKSYPPKColor(R,G,B)  [UIColor colorWithRed:(R * 1.0) / 255.0 green:(G * 1.0) / 255.0 blue:(B * 1.0) / 255.0 alpha:1.0]
#define kKSYPPKRGBA(R,G,B,A)  [UIColor colorWithRed:(R * 1.0) / 255.0 green:(G * 1.0) / 255.0 blue:(B * 1.0) / 255.0 alpha:A]

#define KSYiOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define KSYiOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define KSYiOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define KSYiOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)

#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>

#endif /* KSYPhotoPickerDefines_h */
