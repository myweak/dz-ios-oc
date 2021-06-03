//
//  RrOrderDetailEditCell.h
//  Scanner
//
//  Created by xiao on 2021/5/27.
//  Copyright © 2021 rrdkf. All rights reserved.
//
#define KRrOrderDetailEditCell_ID @"RrOrderDetailEditCell_ID"

#import <UIKit/UIKit.h>
#import "RrDidProductDeTailModel.h"
typedef void(^RrOrderDetailEditCellBlock)(void) ;

NS_ASSUME_NONNULL_BEGIN

@interface RrOrderDetailEditCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *contentViewBg;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *reMarkLabel;
@property (nonatomic, copy) RrOrderDetailEditCellBlock onTapBotton;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (nonatomic, strong) RrDidProductDeTailModel *model;

@end

NS_ASSUME_NONNULL_END
