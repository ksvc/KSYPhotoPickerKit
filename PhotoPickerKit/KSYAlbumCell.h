//
//  KSYAlbumCell.h
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2017/12/5.
//  Copyright © 2017年 ksyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYAlbumModel.h"

@interface KSYAlbumCell : UITableViewCell
@property (nonatomic, strong) KSYAlbumModel *model;
@property (weak, nonatomic  ) IBOutlet UIButton      *selectedCountButton;
@end
