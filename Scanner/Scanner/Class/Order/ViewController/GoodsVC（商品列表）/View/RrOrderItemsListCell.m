//
//  RrOrderItemsListCell.m
//  Scanner
//
//  Created by edz on 2020/7/16.
//  Copyright © 2020 rrdkf. All rights reserved.
//

#import "RrOrderItemsListCell.h"
@interface RrOrderItemsListCell()
@end

@implementation RrOrderItemsListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    [self.contentViewBg bezierPathWithRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadius:7.0f];
    [self.contentViewBg bezierPathWithRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadius:7.0f];
    self.titleLabel.font = KFont20;
    self.subTitleLabel.font = KFont17;
    self.stautsLabel.font = KFont20;
    self.moneyLabel.font = KFont20;
    self.moneyTitleLabel.font = KFont20;


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(RrOrderItemsListModel *)model{
    [self.lfteImageView sd_setImageWithURL:model.cover.url placeholderImage:KPlaceholderImage_product];
    [self.contentViewBg addCornerRadius:7.0f];
    self.titleLabel.text = model.name;
    self.subTitleLabel.text = model.productCode;
//    self.subTitleLabel.text = model.productAbstract;
    self.bottomContentLabel.text = model.aliasName;
    self.moneyLabel.hidden = NO;
    self.moneyLabel.text = [NSString stringWithFormat:@"¥%@",[model.productPrice reviseStringMoney]];
}

@end
