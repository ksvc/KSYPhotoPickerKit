//
//  KSYAlbumModel.m
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2017/11/29.
//  Copyright © 2017年 ksyun.com. All rights reserved.
//

#import "KSYAlbumModel.h"
#import <Photos/Photos.h>

@implementation KSYAssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(KSYAssetModelMediaType)type{
    KSYAssetModel *model = [[KSYAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    
    NSInteger duration = type == KSYAssetModelMediaTypeVideo ? asset.duration : 0;
    model.assetDuration = duration;
    model.timeLength = [self getTimeLengthFromDurationSec:duration];
    return model;
}

+ (NSString *)getTimeLengthFromDurationSec:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}
@end

@implementation KSYAlbumModel
- (instancetype)initWithFetchResult:(PHFetchResult *)result albumName:(NSString *)albumName {
    self = [super init];
    if (self) {
        _result = result;
        _albumName = albumName;
        _assetsCount = result.count;
    }
    return self;
}
@end
