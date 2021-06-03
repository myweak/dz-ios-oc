//
//  RrMineOrderDetailAdressCell.h
//  Scanner
//
//  Created by edz on 2020/7/28.
//  Copyright © 2020 rrdkf. All rights reserved.
//

static NSString *const KOrderDetail_cancelOrder  = @"取消订单";
static NSString *const KOrderDetail_playNotif    = @"支付提醒";
static NSString *const KOrderDetail_send         = @"提醒发货";
static NSString *const KOrderDetail_logistics    = @"查看物流";
static NSString *const KOrderDetail_okGoods      = @"确认收货";
static NSString *const KOrderDetail_complete     = @"去完善";

#define KRrMineOrderDetailAdressCell_ID @"RrMineOrderDetailAdressCell_ID"

typedef void(^RrMineOrderListCellBlock)(NSString *currentTitle) ;

#import <UIKit/UIKit.h>
#import "RrDidProductDeTailModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface RrMineOrderDetailAdressCell : UITableViewCell

/// 高度 默认 60，最小50
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topStautsView_h;
@property (weak, nonatomic) IBOutlet UILabel *topStautsLabel;

///顶部状态 默认隐藏
@property (weak, nonatomic) IBOutlet UIView *topStautsView;

@property (weak, nonatomic) IBOutlet UIView *contenViewBg;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *adressLabel;
///右边尖头 默认隐藏
@property (weak, nonatomic) IBOutlet UIImageView *moreImageView;
///选择地址提示 默认隐藏
@property (weak, nonatomic) IBOutlet UILabel *notifyLabel;

@property (weak, nonatomic) IBOutlet UIView *bottomViewBg;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;

@property (nonatomic, copy) RrMineOrderListCellBlock backBlock;
@property (nonatomic, strong) RrDidProductDeTailModel *model;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftBtn_xr;


/// 倒计时到0时回调
@property (nonatomic, copy) void(^countDownZero)(RrDidProductDeTailModel *);
- (void)startTime;//开始倒计时

@end

NS_ASSUME_NONNULL_END
