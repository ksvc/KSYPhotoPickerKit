//
//  KSYAssetCell.h
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2018/3/8.
//  Copyright © 2018年 ksyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger,KSYAssetCellType) {
    KSYAssetCellTypePhoto = 0,
    KSYAssetCellTypeLivePhoto,
    KSYAssetCellTypePhotoGif,
    KSYAssetCellTypeVideo,
    KSYAssetCellTypeAudio,
};

@class KSYAssetModel;
@interface KSYAssetCell : UICollectionViewCell
@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL);
@property (weak, nonatomic  ) IBOutlet UIButton         *selectPhotoButton;
@property (nonatomic, strong) KSYAssetModel    *model;
@property (nonatomic, assign) KSYAssetCellType type;
@property (nonatomic, assign) BOOL             allowPickingGif;
@property (nonatomic, assign) BOOL             allowPickingMultipleVideo;
@property (nonatomic, copy  ) NSString         *representedAssetIdentifier;
@property (nonatomic, assign) int32_t          imageRequestID;
@property (nonatomic, copy  ) NSString         *photoSelImageName;
@property (nonatomic, copy  ) NSString         *photoDefImageName;
@property (nonatomic, assign) BOOL             showSelectBtn;
//@property (assign, nonatomic) BOOL             allowPreview;
@end
