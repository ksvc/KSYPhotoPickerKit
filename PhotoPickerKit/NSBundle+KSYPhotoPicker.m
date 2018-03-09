//
//  NSBundle+KSYPhotoPicker.m
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2018/3/8.
//  Copyright © 2018年 ksyun.com. All rights reserved.
//

#import "NSBundle+KSYPhotoPicker.h"
#import "KSYPhotoPickerController.h"
@implementation NSBundle (KSYPhotoPicker)
+ (NSBundle *)ksy_imagePickerBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[KSYPhotoPickerController class]];
    NSURL *url = [bundle URLForResource:@"KSYPhotoResources" withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:url];
    return bundle;
}
@end


@implementation UIImage (MyBundle)

+ (UIImage *)imageNamedFromMyBundle:(NSString *)name {
    NSBundle *imageBundle = [NSBundle ksy_imagePickerBundle];
    name = [name stringByAppendingString:@"@2x"];
    NSString *imagePath = [imageBundle pathForResource:name ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (!image) {
        // 兼容业务方自己设置图片的方式
        name = [name stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
        image = [UIImage imageNamed:name];
    }
    return image;
}



@end

@implementation UIView (KSYAnimation)
+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(KSYOscillatoryAnimationType)type{
    NSNumber *animationScale1 = type == KSYOscillatoryAnimationToBigger ? @(1.15) : @(0.5);
    NSNumber *animationScale2 = type == KSYOscillatoryAnimationToBigger ? @(0.92) : @(1.15);
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        [layer setValue:animationScale1 forKeyPath:@"transform.scale"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            [layer setValue:animationScale2 forKeyPath:@"transform.scale"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                [layer setValue:@(1.0) forKeyPath:@"transform.scale"];
            } completion:nil];
        }];
    }];
}
@end
