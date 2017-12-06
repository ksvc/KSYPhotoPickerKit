//
//  KSYAlbumCell.m
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2017/12/5.
//  Copyright © 2017年 ksyun.com. All rights reserved.
//

#import "KSYAlbumCell.h"
#import <HandyAutoLayout/UIView+HandyAutoLayout.h>

@interface KSYAlbumCell()
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation KSYAlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self configCellSubviews];
}

- (void)configCellSubviews{
    [self.contentView addConstraint:[self.posterImageView constraintLeftEqualToView:self.contentView]];
    [self.contentView addConstraint:[self.posterImageView constraintTopEqualToView:self.contentView]];
    [self.contentView addConstraint:[self.posterImageView constraintBottomEqualToView:self.contentView]];
    [self.contentView addConstraint:[self.posterImageView constraintWidth:70]];
    
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
