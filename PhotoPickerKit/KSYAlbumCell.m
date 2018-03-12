//
//  KSYAlbumCell.m
//  KSYPhotoPickerKit
//
//  Created by sunyazhou on 2017/12/5.
//  Copyright © 2017年 ksyun.com. All rights reserved.
//

#import "KSYAlbumCell.h"
#import "KSYPhotoManager.h"


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
    [self.posterImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.contentView);
        make.width.equalTo(@70);
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.posterImageView.mas_right).offset(10);
        make.right.equalTo(self.contentView.mas_right).offset(-5);
        make.centerY.equalTo(self.posterImageView.mas_centerY);
        make.height.equalTo(@30);
    }];
    self.posterImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.posterImageView.clipsToBounds = YES;
    
    
    [self.selectedCountButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-5.);
        make.centerY.equalTo(self.titleLabel.mas_centerY);
        make.width.height.equalTo(@24);
    }];
    self.selectedCountButton.layer.cornerRadius = 12;
    self.selectedCountButton.clipsToBounds = YES;
    self.selectedCountButton.backgroundColor = [UIColor redColor];
    [self.selectedCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.selectedCountButton.titleLabel.font = [UIFont systemFontOfSize:15];
}

- (void)setModel:(KSYAlbumModel *)model{
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:model.albumName attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",model.assetsCount] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    self.titleLabel.attributedText = nameString;
    [[KSYPhotoManager defaultManager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
        self.posterImageView.image = postImage;
    }];
    if (model.selectedCount) {
        self.selectedCountButton.hidden = NO;
        [self.selectedCountButton setTitle:[NSString stringWithFormat:@"%zd",model.selectedCount] forState:UIControlStateNormal];
    } else {
        self.selectedCountButton.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
