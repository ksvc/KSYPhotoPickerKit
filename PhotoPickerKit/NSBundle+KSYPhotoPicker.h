//
//  NSBundle+KSYPhotoPicker.h
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2018/3/8.
//  Copyright © 2018年 ksyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,KSYOscillatoryAnimationType) {
    KSYOscillatoryAnimationToBigger = 0,
    KSYOscillatoryAnimationToSmaller = 1
};

@interface NSBundle (KSYPhotoPicker)
+ (NSBundle *)ksy_imagePickerBundle;
@end


@interface UIImage (MyBundle)
+ (UIImage *)imageNamedFromMyBundle:(NSString *)name;


@end

@interface UIView (KSYAnimation)
+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer
                                     type:(KSYOscillatoryAnimationType)type;
@end
