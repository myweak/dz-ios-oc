//
//  RrOrderItemsListCell.h
//  Scanner
//
//  Created by edz on 2020/7/16.
//  Copyright © 2020 rrdkf. All rights reserved.
//

#define KRrOrderItemsListCell_ID @"RrOrderItemsListCell_ID"
#import "RrOrderItemsListModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RrOrderItemsListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *contentViewBg;
@property (weak, nonatomic) IBOutlet UIImageView *lfteImageView;
/// 图片宽 默认85
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lfteImageView_w;


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
/// 商品价格
@property (weak, nonatomic) IBOutlet UILabel *rightTitleLabel;


@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
///subTitleLabel 右边的label。 商品数量x3
@property (weak, nonatomic) IBOutlet UILabel *rightSubLabel;


/// subTitleLabel 底下label 详情规格
@property (weak, nonatomic) IBOutlet UILabel *subTwoLabel;

///与图片底部平齐的。品名label
@property (weak, nonatomic) IBOutlet UILabel *bottomContentLabel;

@property (weak, nonatomic) IBOutlet UILabel *moneyLabel; // 默认隐藏
@property (weak, nonatomic) IBOutlet UILabel *moneyTitleLabel; //小计

@property (weak, nonatomic) IBOutlet UILabel *stautsLabel; // 默认隐藏


/// 数据模型
@property (strong, nonatomic) RrOrderItemsListModel *model;

@end

NS_ASSUME_NONNULL_END
